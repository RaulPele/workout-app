//
//  WatchCommunicator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 24.05.2023.
//

import Foundation
import WatchConnectivity
import OSLog

class WatchCommunicator: NSObject, WCSessionDelegate {
    
    private let session = WCSession.default
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let logger = Logger()

    
    override init() {
        super.init()
        if WCSession.isSupported() {
            print("Session is supported phone.")
            session.delegate = self
            session.activate()
        } else {
            print("Session is not supported on phone.")
        }
    }
    
    private func send(message: Message) throws{
        let json = try encoder.encode(message)
        session.sendMessageData(json) { response in
            print("Received Response: \(response)")
        }
    }
    
    func send(workoutTemplates: [WorkoutTemplate]) throws  {
        let data = try encoder.encode(workoutTemplates)
        try send(message: .init(contentType: .workoutTemplates, data: data))
    }
    
    func send(_ message: String) throws {
        let data = try encoder.encode(message)
        session.sendMessageData(data, replyHandler: nil)
        print("Sent message to watch: \(message)")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        logger.log("Session activation complete with state: \(activationState.rawValue)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        logger.log("Session did become inactive.")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        logger.log("Session did deactivate")
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        do {
            let message = try decoder.decode(Message.self, from: messageData)
            switch message.contentType {
            case .workoutSession:
                let workoutSession = try decoder.decode(Workout.self, from: message.data)
                logger.info("Received workout session from Watch: \(workoutSession.id)")
                print("Received workout session from Watch: \(workoutSession)")
                try FileIOManager.write(entity: workoutSession, toDirectory: .workoutSessions)
                
            default: break
            }
        } catch {
            print("Error while receiving message with no reply handler on PHONE: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        var replyData: Data = .init()
        do {
            let message = try decoder.decode(Message.self, from: messageData)
            switch message.contentType {
            case .workoutTemplates:
                let templates: [WorkoutTemplate] = try FileIOManager.readAll(from: .workoutTemplates)
                logger.info("Read workout templates from file: \(templates)")
                replyData = try encoder.encode(templates)
                
            case .workoutSession:
                break
            }
        } catch {
            print("Error in watchc communicator while reading templates: \(error.localizedDescription)")
        }
        replyHandler(replyData)

    }
    
}
