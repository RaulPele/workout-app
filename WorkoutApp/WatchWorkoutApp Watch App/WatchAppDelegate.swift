//
//  WatchAppDelegate.swift
//  WatchWorkoutApp Watch App
//

import WatchKit

/// Owns the `WorkoutManager` so workout recovery can run as soon as the app launches.
final class WatchAppDelegate: NSObject, WKApplicationDelegate {

    // MARK: - Properties
    let workoutManager = WorkoutManager()

    // MARK: - WKApplicationDelegate
    func applicationDidFinishLaunching() {
        Task {
            await workoutManager.recoverActiveWorkoutIfNeeded()
        }
    }

    /// Called when the system relaunches the app after it crashed during a workout session.
    func handleActiveWorkoutRecovery() {
        Task {
            await workoutManager.recoverActiveWorkout()
        }
    }
}
