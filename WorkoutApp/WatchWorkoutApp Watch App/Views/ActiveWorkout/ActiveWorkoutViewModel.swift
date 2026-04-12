//
//  ActiveWorkoutViewModel.swift
//  WatchWorkoutApp Watch App
//

import Foundation

@MainActor @Observable
final class ActiveWorkoutViewModel {

    // MARK: - Properties
    let workout: Workout
    private(set) var exerciseQueue: [Exercise]
    private(set) var currentExerciseIndex: Int = 0
    private(set) var performedExercises: [PerformedExercise] = []
    private(set) var exerciseTrackingViewModel: ExerciseTrackingViewModel

    // MARK: - Computed Properties
    var currentExercise: Exercise {
        exerciseQueue[currentExerciseIndex]
    }

    var exerciseCount: Int {
        exerciseQueue.count
    }

    var completedExerciseCount: Int {
        performedExercises.count
    }

    var isLastExercise: Bool {
        currentExerciseIndex >= exerciseQueue.count - 1
    }

    var nextExerciseName: String? {
        guard !isLastExercise else { return nil }
        return exerciseQueue[currentExerciseIndex + 1].name
    }

    var remainingExercises: [Exercise] {
        guard currentExerciseIndex + 1 < exerciseQueue.count else { return [] }
        return Array(exerciseQueue[(currentExerciseIndex + 1)...])
    }

    // MARK: - Initializers
    init(workout: Workout) {
        self.workout = workout
        self.exerciseQueue = workout.exercises
        self.exerciseTrackingViewModel = ExerciseTrackingViewModel(exercise: workout.exercises[0])
    }

    #if DEBUG
    init(workout: Workout, exerciseTrackingViewModel: ExerciseTrackingViewModel) {
        self.workout = workout
        self.exerciseQueue = workout.exercises
        self.exerciseTrackingViewModel = exerciseTrackingViewModel
    }
    #endif

    // MARK: - Public Methods
    func completeExercise(_ performed: PerformedExercise) {
        performedExercises.append(performed)
        if !isLastExercise {
            currentExerciseIndex += 1
            exerciseTrackingViewModel = ExerciseTrackingViewModel(exercise: currentExercise)
        }
    }

    func swapExercise(with chosen: Exercise) {
        guard let chosenIndex = exerciseQueue.firstIndex(where: { $0.id == chosen.id }),
              chosenIndex != currentExerciseIndex else { return }

        let current = exerciseQueue[currentExerciseIndex]

        let removedChosen = exerciseQueue.remove(at: chosenIndex)
        let adjustedCurrentIndex = chosenIndex < currentExerciseIndex
            ? currentExerciseIndex - 1
            : currentExerciseIndex
        exerciseQueue.remove(at: adjustedCurrentIndex)

        exerciseQueue.insert(removedChosen, at: adjustedCurrentIndex)
        exerciseQueue.insert(current, at: adjustedCurrentIndex + 1)

        exerciseTrackingViewModel = ExerciseTrackingViewModel(exercise: currentExercise)
    }
}
