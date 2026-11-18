//
//  ActiveWorkoutViewModel.swift
//  WatchWorkoutApp Watch App
//

import Foundation

@MainActor @Observable
final class ActiveWorkoutViewModel {

    // MARK: - Properties
    let template: Workout
    let exerciseTracking: ExerciseTrackingViewModel
    private let workoutManager: WorkoutManager

    // MARK: - Computed Properties
    var isRunning: Bool {
        workoutManager.running
    }

    var startErrorMessage: String? {
        guard case .failedToStart(let message) = workoutManager.lifecycle else { return nil }
        return message
    }

    // MARK: - Initializers
    init(template: Workout, workoutManager: WorkoutManager) {
        self.template = template
        self.workoutManager = workoutManager
        self.exerciseTracking = ExerciseTrackingViewModel(workoutManager: workoutManager)
    }

    // MARK: - Public Methods
    /// Starts (or retries starting) the workout; a no-op once it is running.
    func start() async {
        await workoutManager.startWorkout(template: template)
    }

    func cancelStart() {
        workoutManager.discardWorkout()
    }
}
