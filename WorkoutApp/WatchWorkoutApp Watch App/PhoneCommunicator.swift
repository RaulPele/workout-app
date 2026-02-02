//
//  PhoneCommunicator.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 24.05.2023.
//

import Foundation
import WatchConnectivity
import OSLog

class PhoneCommunicator: NSObject, WCSessionDelegate {
    
    private let logger = CustomLogger(subsystem: Bundle.main.bundleIdentifier ?? Constants.appName, category: String(describing: PhoneCommunicator.self))
    private let session = WCSession.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            logger.info("WCSession is supported on watch")
            session.delegate = self
            session.activate()
        }
    }
    
    private func send(message: Message, replyHandler: ((Data) -> Void)?) throws {
        let json = try encoder.encode(message)
        if session.isReachable {
            logger.info("Session is reachable")
        } else {
            logger.info("Session is NOT reachable.")
        }
        
        session.sendMessageData(json, replyHandler: replyHandler)
    }
    
    
    func requestWorkoutTemplates(completion: @escaping ([Workout]) -> Void) throws {
        
        let message = Message(contentType: .workoutTemplates, data: Data())
        print("Requesting workout templates")
        try send(message: message) { [weak self] response in
            var templates = [Workout]()
            self?.logger.debug("Decoding workout templates")

            do {
                templates = try JSONDecoder().decode([Workout].self, from: response)
            } catch {
                self?.logger.error("Error occured while decoding templates \(error.localizedDescription)")
            }
            completion(templates)
        }
        
    }
    
    func send(workoutSession: WorkoutSession) throws {
        let sessionData = try encoder.encode(workoutSession)
        let message = Message(contentType: .workoutSession, data: sessionData)
        try send(message: message, replyHandler: nil)
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        logger.info("Session activated with state \(activationState.rawValue)")
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
//        logger.log("Received message from phone: \(String(data: messageData, encoding: .utf8))")
        logger.info("Received message from phone: \(String(data: messageData, encoding: .utf8))")
    }
}
//1093706E-5897-49A2-ABE4-364B3744CD1B id sent from watch
