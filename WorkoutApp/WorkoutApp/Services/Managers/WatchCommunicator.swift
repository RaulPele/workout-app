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

    // MARK: - Properties
    private let workoutRepository: any WorkoutRepository
    let workoutSessionRepository: any WorkoutSessionRepository

    private let session = WCSession.default

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? Constants.appName,
        category: String(describing: WatchCommunicator.self)
    )

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializers
    init(workoutRepository: any WorkoutRepository,
         workoutSessionRepository: any WorkoutSessionRepository) {
        self.workoutRepository = workoutRepository
        self.workoutSessionRepository = workoutSessionRepository
        super.init()
        configure()
    }

    // MARK: - Private Methods

    private func configure() {
        guard WCSession.isSupported() else {
            logger.info("Session is not supported on phone.")
            return
        }
        
        logger.info("Session is supported on phone.")
        session.delegate = self
        session.activate()
    }

    private func subscribeToWorkoutsPublisher() {
        workoutRepository
            .entitiesPublisher
            .sink { [weak self] workouts in
                self?.updateApplicationContext(with: workouts)
            }
            .store(in: &cancellables)
    }

    private func updateApplicationContext(with workouts: [Workout]) {
        do {
            let context = try WatchMessage.workoutTemplates(workouts).toDictionary()
            try session.updateApplicationContext(context)
            logger.info("Updated application context with \(workouts.count) workout templates")
        } catch {
            logger.error("Failed to update application context: \(error.localizedDescription)")
        }
    }

    // MARK: - WCSessionDelegate

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

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        logger.info("Received user info from watch")
        do {
            let message = try WatchMessage.fromDictionary(userInfo)
            if case .workoutSession(let workoutSession) = message {
                logger.info("Received workout session from Watch: \(workoutSession.id)")
                Task {
                    try await workoutSessionRepository.save(entity: workoutSession)
                    logger.info("Saved workout session \(workoutSession.id) via repository")
                }
            }
        } catch {
            logger.error("Failed to decode user info: \(error.localizedDescription)")
        }
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        Task {
            var replyData: Data = .init()
            do {
                let message = try WatchMessage.fromData(messageData)
                switch message {
                case .requestTemplates:
                    logger.info("Received request for workout templates from Watch")

                    try await workoutRepository.loadData()

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

                default:
                    break
                }
            } catch {
                logger.error("Error in watch communicator while reading templates: \(error.localizedDescription)")
            }
            replyHandler(replyData)
        }
    }
}
