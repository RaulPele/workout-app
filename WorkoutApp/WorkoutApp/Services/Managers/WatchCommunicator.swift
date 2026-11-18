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

// MARK: - Protocol
protocol WatchCommunicatorProtocol: AnyObject {}

// MARK: - WatchCommunicator
class WatchCommunicator: NSObject, WCSessionDelegate, WatchCommunicatorProtocol {

    // MARK: - Properties
    private let workoutRepository: any WorkoutRepository
    private let workoutSessionRepository: any WorkoutSessionRepository
    private let sessionInbox: WorkoutSessionInbox

    private let session = WCSession.default

    private let encoder = JSONEncoder()
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
        self.sessionInbox = WorkoutSessionInbox(repository: workoutSessionRepository)
        super.init()
        subscribeToWorkoutsPublisher()
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

    /// Mirrors every template change into the application context.
    ///
    /// Subscribed once, here rather than on activation, so re-activating after a watch
    /// switch doesn't stack subscriptions. `dropFirst()` skips the repository's initial
    /// placeholder (`[]` before anything has loaded), which would otherwise replace the
    /// watch's cached list with nothing; activation triggers a real load instead.
    private func subscribeToWorkoutsPublisher() {
        workoutRepository
            .entitiesPublisher
            .dropFirst()
            .sink { [weak self] workouts in
                self?.updateApplicationContext(with: workouts)
            }
            .store(in: &cancellables)
    }

    private func updateApplicationContext(with workouts: [Workout]) {
        guard session.activationState == .activated else {
            logger.debug("Session not activated yet, skipping application context update")
            return
        }

        do {
            let context = try WatchMessage.workoutTemplates(workouts).toDictionary()
            try session.updateApplicationContext(context)
            logger.info("Updated application context with \(workouts.count) workout templates")
        } catch {
            logger.error("Failed to update application context: \(error.localizedDescription)")
        }
    }

    /// Loads templates from storage; the subscription pushes the result to the watch.
    private func reloadTemplates() async {
        do {
            try await workoutRepository.loadData()
        } catch {
            logger.error("Failed to load workout templates for the watch: \(error.localizedDescription)")
        }
    }

    /// Last resort when a session can't be written to the inbox: save it straight away.
    private func saveDirectly(_ workoutSession: WorkoutSession) async {
        do {
            try await workoutSessionRepository.save(entity: workoutSession)
            logger.info("Saved workout session \(workoutSession.id) directly")
        } catch {
            logger.error("Failed to save workout session \(workoutSession.id): \(error.localizedDescription)")
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error {
            logger.error("Session activation failed: \(error.localizedDescription)")
        }
        logger.info("Session activation complete with state: \(activationState.rawValue)")
        guard activationState == .activated else { return }

        // Push the real template list to the (possibly newly paired) watch.
        Task { await reloadTemplates() }
        // Retry sessions an earlier launch received but couldn't save.
        Task { await sessionInbox.drain() }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        logger.info("Session did become inactive.")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // The user switched to another Apple Watch. The session must be activated again to
        // connect to it; activation then re-pushes the templates.
        logger.info("Session did deactivate, reactivating for the newly active watch")
        session.activate()
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        logger.info("Received user info from watch")

        let workoutSession: WorkoutSession
        do {
            guard case .workoutSession(let received) = try WatchMessage.fromDictionary(userInfo) else { return }
            workoutSession = received
        } catch {
            logger.error("Failed to decode user info: \(error.localizedDescription)")
            return
        }
        logger.info("Received workout session from Watch: \(workoutSession.id)")

        // WatchConnectivity considers the transfer delivered once this method returns, so
        // persist it before returning and save from disk.
        do {
            try sessionInbox.store(workoutSession)
        } catch {
            logger.error("Failed to persist workout session \(workoutSession.id) to the inbox: \(error.localizedDescription)")
            Task { await saveDirectly(workoutSession) }
            return
        }
        Task { await sessionInbox.drain() }
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        Task {
            var replyData: Data = .init()
            do {
                let message = try WatchMessage.fromData(messageData)
                switch message {
                case .requestTemplates:
                    logger.info("Received request for workout templates from Watch")

                    do {
                        try await workoutRepository.loadData()
                    } catch {
                        logger.error("Failed to load workout data: \(error.localizedDescription)")
                    }

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

// MARK: - MockedWatchCommunicator
class MockedWatchCommunicator: WatchCommunicatorProtocol {}
