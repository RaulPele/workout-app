//
//  ActiveWorkoutViewModel.swift
//  WatchWorkoutApp Watch App
//

import Foundation
import WatchKit

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

    // MARK: - Initializers
    init(template: Workout, workoutManager: WorkoutManager) {
        self.template = template
        self.workoutManager = workoutManager
        self.exerciseTracking = ExerciseTrackingViewModel(workoutManager: workoutManager)
    }

    // MARK: - Public Methods
    func start() async {
        WKInterfaceDevice.current().play(.start)
        await workoutManager.startWorkout(template: template)
    }
}
