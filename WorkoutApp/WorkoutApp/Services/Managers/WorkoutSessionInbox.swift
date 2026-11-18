//
//  WorkoutSessionInbox.swift
//  WorkoutApp
//
//  Created by Raul Pele on 12.11.2026.
//

import Foundation

// MARK: - WorkoutSessionInbox
/// Durable hand-off for workout sessions received from the watch.
///
/// WatchConnectivity treats a `transferUserInfo` payload as delivered as soon as the
/// delegate method returns, and the watch keeps no copy. Each session is written to disk
/// before that method returns and is only removed once the repository has saved it, so a
/// failed save is retried on the next `drain()` instead of losing the workout.
actor WorkoutSessionInbox {

    // MARK: - Properties
    private let repository: any WorkoutSessionRepository
    private let directory: URL
    private let decoder = JSONDecoder()
    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? Constants.appName,
        category: String(describing: WorkoutSessionInbox.self)
    )

    private var isDraining = false
    private var needsAnotherPass = false

    // MARK: - Initializers
    init(
        repository: any WorkoutSessionRepository,
        directory: URL = .applicationSupportDirectory.appending(path: "PendingWorkoutSessions", directoryHint: .isDirectory)
    ) {
        self.repository = repository
        self.directory = directory
    }

    // MARK: - Public Methods
    /// Writes `session` to disk. Synchronous so it finishes before the
    /// WatchConnectivity delegate method returns.
    nonisolated func store(_ session: WorkoutSession) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(session)
        try data.write(to: fileURL(for: session.id), options: .atomic)
    }

    /// Saves every pending session through the repository and removes each one once it's
    /// stored. Sessions that fail to save stay on disk for the next call.
    ///
    /// Calls that arrive while a drain is running are folded into one extra pass, so the
    /// same session is never saved concurrently (the repository's upsert isn't atomic).
    func drain() async {
        guard !isDraining else {
            needsAnotherPass = true
            return
        }
        isDraining = true
        defer { isDraining = false }

        repeat {
            needsAnotherPass = false
            for pending in pendingSessions() {
                do {
                    try await repository.save(entity: pending.session)
                    try FileManager.default.removeItem(at: pending.url)
                    logger.info("Saved pending workout session \(pending.session.id)")
                } catch {
                    logger.error("Failed to save pending workout session \(pending.session.id), will retry: \(error.localizedDescription)")
                }
            }
        } while needsAnotherPass
    }

    // MARK: - Private Methods
    private nonisolated func fileURL(for id: UUID) -> URL {
        directory.appending(path: "\(id.uuidString).json")
    }

    private func pendingSessions() -> [(url: URL, session: WorkoutSession)] {
        let urls: [URL]
        do {
            urls = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        } catch {
            // The directory only exists once something has been stored.
            return []
        }

        return urls
            .filter { $0.pathExtension == "json" }
            .compactMap { url -> (url: URL, session: WorkoutSession)? in
                do {
                    let session = try decoder.decode(WorkoutSession.self, from: Data(contentsOf: url))
                    return (url, session)
                } catch {
                    logger.error("Skipping unreadable pending workout session \(url.lastPathComponent): \(error.localizedDescription)")
                    return nil
                }
            }
    }
}
