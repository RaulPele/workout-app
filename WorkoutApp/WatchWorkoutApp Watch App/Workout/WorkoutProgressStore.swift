//
//  WorkoutProgressStore.swift
//  WatchWorkoutApp Watch App
//

import Foundation

// MARK: - Protocol
/// Persists the active workout's progress so logged sets survive a crash or force-quit.
protocol WorkoutProgressStoring {
    func load() -> WorkoutProgress?
    func save(_ progress: WorkoutProgress)
    func clear()
}

// MARK: - FileWorkoutProgressStore
/// Stores progress as JSON in Application Support. Writes are atomic, so a crash
/// mid-write leaves the previous snapshot intact.
struct FileWorkoutProgressStore: WorkoutProgressStoring {

    // MARK: - Properties
    private let fileURL: URL
    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? Constants.appName,
        category: "WorkoutProgressStore"
    )

    // MARK: - Initializers
    init(fileURL: URL = .applicationSupportDirectory.appending(path: "ActiveWorkout/progress.json")) {
        self.fileURL = fileURL
    }

    // MARK: - Public Methods
    func load() -> WorkoutProgress? {
        guard FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) else { return nil }

        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(WorkoutProgress.self, from: data)
        } catch {
            logger.error("Discarding unreadable workout progress: \(error.localizedDescription)")
            clear()
            return nil
        }
    }

    func save(_ progress: WorkoutProgress) {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try JSONEncoder().encode(progress)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
        } catch {
            logger.error("Failed to save workout progress: \(error.localizedDescription)")
        }
    }

    func clear() {
        guard FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) else { return }

        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            logger.error("Failed to clear workout progress: \(error.localizedDescription)")
        }
    }
}

// MARK: - InMemoryWorkoutProgressStore
final class InMemoryWorkoutProgressStore: WorkoutProgressStoring {

    private var progress: WorkoutProgress?

    init(progress: WorkoutProgress? = nil) {
        self.progress = progress
    }

    func load() -> WorkoutProgress? {
        progress
    }

    func save(_ progress: WorkoutProgress) {
        self.progress = progress
    }

    func clear() {
        progress = nil
    }
}
