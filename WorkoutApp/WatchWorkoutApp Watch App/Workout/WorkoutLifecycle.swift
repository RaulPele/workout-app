//
//  WorkoutLifecycle.swift
//  WatchWorkoutApp Watch App
//

import Foundation

/// Where the active workout is between starting and the summary being dismissed.
enum WorkoutLifecycle: Equatable {
    case idle
    case starting
    case failedToStart(message: String)
    case active
    /// End was requested; the summary is shown while HealthKit saves.
    case saving
    case finished
    case saveFailed(message: String)

    // MARK: - Computed Properties
    var isShowingSummary: Bool {
        switch self {
        case .saving, .finished, .saveFailed:
            true
        case .idle, .starting, .failedToStart, .active:
            false
        }
    }

    /// Sets can be logged and the workout ended.
    var isInProgress: Bool {
        self == .starting || self == .active
    }
}
