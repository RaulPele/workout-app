//
//  WatchCommunicator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 24.05.2023.
//

import Foundation
import WatchConnectivity
import OSLog
import Combine

class WatchCommunicator: NSObject, WCSessionDelegate {
    
    let workoutRepository: any WorkoutRepository
    
    private let session = WCSession.default
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? Constants.appName,
        category: String(describing: WatchCommunicator.self)
    )
    
    private var cancellables = Set<AnyCancellable>()
    
    
    init(workoutRepository: any WorkoutRepository) {
        self.workoutRepository = workoutRepository
        super.init()
        configure()
    }
    
    private func configure() {
        if WCSession.isSupported() {
            logger.info("Session is supported phone.")
            session.delegate = self
            session.activate()
        } else {
            logger.info("Session is not supported on phone.")
        }
        
    }
    
    private func subscribeToWorkoutsPublisher() {
        workoutRepository
            .entitiesPublisher
            .sink { [weak self] workouts in
                try? self?.send(workoutTemplates: workouts) //TODO: handle errors somehow
            }
            .store(in: &cancellables)
    }
    
    private func send(message: Message) throws{ // TODO: might need to checks to isPaired and isWatchAppInstalled, ActivationState.activated
        let json = try encoder.encode(message)
        session.sendMessageData(json) { [weak self] response in
            self?.logger.debug("Received Response: \(response)")
        }
    }
    
    func send(workoutTemplates: [Workout]) throws  {
        let data = try encoder.encode(workoutTemplates)
        try send(message: Message(contentType: .workoutTemplates, data: data))
    }
    
    func send(_ message: String) throws {
        let data = try encoder.encode(message)
        session.sendMessageData(data, replyHandler: nil)
        logger.debug("Sent message to watch: \(message)")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        logger.info("Session activation complete with state: \(activationState.rawValue)")
        guard activationState == .activated else { return }
        subscribeToWorkoutsPublisher()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        logger.info("Session did become inactive.")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        logger.info("Session did deactivate")
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        do {
            let message = try decoder.decode(Message.self, from: messageData)
            switch message.contentType {
            case .workoutSession:
                let workoutSession = try decoder.decode(WorkoutSession.self, from: message.data)
                logger.info("Received workout session from Watch: \(workoutSession.id)")
                try FileIOManager.write(entity: workoutSession, toDirectory: .workoutSessions) //TODO: change
                
            default: break
            }
        } catch {
            logger.debug("Error while receiving message with no reply handler on PHONE: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        Task {
            var replyData: Data = .init()
            do {
                let message = try decoder.decode(Message.self, from: messageData)
                switch message.contentType {
                case .workoutTemplates:
                    logger.info("Received request for workout templates from Watch")
                    
                    // Load latest workouts from repository
                    try await workoutRepository.loadData()
                    
                    // Get workouts from publisher's current value
                    let workouts = await withCheckedContinuation { continuation in
                        var cancellable: AnyCancellable?
                        cancellable = workoutRepository.entitiesPublisher
                            .first()
                            .sink { workouts in
                                continuation.resume(returning: workouts)
                                cancellable?.cancel()
                            }
                    }
                    
                    logger.info("Sending \(workouts.count) workout templates to Watch")
                    replyData = try encoder.encode(workouts)
                    
                case .workoutSession:
                    break
                }
            } catch {
                logger.error("Error in watch communicator while reading templates: \(error.localizedDescription)")
            }
            replyHandler(replyData)
        }
    }
    
}
