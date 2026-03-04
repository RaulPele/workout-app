//
//  PhoneCommunicator.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 24.05.2023.
//

import Foundation
import WatchConnectivity
import OSLog
import Combine

// MARK: - Protocol
protocol PhoneCommunicatorProtocol {
    var templatesPublisher: AnyPublisher<[Workout], Never> { get }
    func requestWorkoutTemplates() async throws -> [Workout]
    func send(workoutSession: WorkoutSession)
}

// MARK: - PhoneCommunicator
class PhoneCommunicator: NSObject, WCSessionDelegate, PhoneCommunicatorProtocol {

    // MARK: - Properties
    var templatesPublisher: AnyPublisher<[Workout], Never> {
        templatesSubject.eraseToAnyPublisher()
    }

    private let templatesSubject = CurrentValueSubject<[Workout], Never>([])
    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? Constants.appName,
        category: String(describing: PhoneCommunicator.self)
    )
    private let session = WCSession.default
    private let decoder = JSONDecoder()

    // MARK: - Initializers
    override init() {
        super.init()

        configure()
    }
    
    // MARK: - Public Methods
    func send(workoutSession: WorkoutSession) {
        do {
            let userInfo = try WatchMessage.workoutSession(workoutSession).toDictionary()
            session.transferUserInfo(userInfo)
            logger.info("Queued workout session for transfer via transferUserInfo")
        } catch {
            logger.error("Failed to encode workout session for transfer: \(error.localizedDescription)")
        }
    }

    func requestWorkoutTemplates() async throws -> [Workout] {
        let requestData = try WatchMessage.requestTemplates.toData()

        logger.info("Requesting workout templates")

        guard session.isReachable else {
            logger.info("Phone not reachable, falling back to cached application context")
            return templatesFromCachedContext()
        }

        return try await withCheckedThrowingContinuation { continuation in
            session.sendMessageData(requestData, replyHandler: { [weak self] response in
                guard let self else { return }
                self.logger.debug("Decoding workout templates from reply")
                do {
                    let templates = try self.decoder.decode([Workout].self, from: response)
                    continuation.resume(returning: templates)
                } catch {
                    self.logger.error("Error decoding templates: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }, errorHandler: { [weak self] error in
                guard let self else { return }
                self.logger.error("sendMessageData failed: \(error.localizedDescription), falling back to cached context")
                let cached = self.templatesFromCachedContext()
                continuation.resume(returning: cached)
            })
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        logger.info("Session activated with state \(activationState.rawValue)")
        if activationState == .activated {
            let cached = templatesFromCachedContext()
            if !cached.isEmpty {
                logger.info("Found \(cached.count) templates in cached application context on activation")
                templatesSubject.send(cached)
            }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        logger.info("Received application context from phone")
        do {
            let message = try WatchMessage.fromDictionary(applicationContext)
            if case .workoutTemplates(let templates) = message {
                logger.info("Decoded \(templates.count) templates from application context")
                templatesSubject.send(templates)
            }
        } catch {
            logger.error("Failed to decode application context: \(error.localizedDescription)")
        }
    }

    // MARK: - Private Methods
    private func configure() {
        guard WCSession.isSupported() else {
            logger.info("WCSession is not support on watch!")
            return
        }
        logger.info("WCSession is supported on watch")
        session.delegate = self
        session.activate()
    }
    
    private func templatesFromCachedContext() -> [Workout] {
        let context = session.receivedApplicationContext
        guard !context.isEmpty else { return [] }

        do {
            let message = try WatchMessage.fromDictionary(context)
            if case .workoutTemplates(let templates) = message {
                return templates
            }
        } catch {
            logger.error("Failed to decode cached application context: \(error.localizedDescription)")
        }
        return []
    }
}

// MARK: - MockedPhoneCommunicator
class MockedPhoneCommunicator: PhoneCommunicatorProtocol {

    private let templatesSubject = CurrentValueSubject<[Workout], Never>([])

    var templatesPublisher: AnyPublisher<[Workout], Never> {
        templatesSubject.eraseToAnyPublisher()
    }

    func requestWorkoutTemplates() async throws -> [Workout] {
        [.mockedWorkoutTemplate, .mockedWorkoutTemplate2()]
    }

    func send(workoutSession: WorkoutSession) {}
}
