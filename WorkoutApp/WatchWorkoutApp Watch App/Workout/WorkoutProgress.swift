//
//  WorkoutProgress.swift
//  WatchWorkoutApp Watch App
//

import Foundation

/// The user's progress through an active workout: the exercise queue, the exercises
/// already completed, and the sets logged for the current exercise.
///
/// A value type so `WorkoutManager` owns the single source of truth for the session,
/// independent of which views are on screen.
struct WorkoutProgress: Codable, Hashable {

    // MARK: - LogSetOutcome
    enum LogSetOutcome {
        case resting
        case nextExercise
        case workoutComplete
    }

    // MARK: - Properties
    let template: Workout
    let startDate: Date
    private(set) var exerciseQueue: [Exercise]
    private(set) var currentExerciseIndex = 0
    private(set) var currentExerciseID = UUID()
    private(set) var completedExercises: [PerformedExercise] = []
    private(set) var currentSets: [PerformedSet] = []
    private(set) var restStartDate: Date?
    private(set) var isComplete = false

    // MARK: - Initializers
    init(template: Workout, startDate: Date) {
        self.template = template
        self.startDate = startDate
        self.exerciseQueue = template.exercises
    }

    // MARK: - Computed Properties
    var currentExercise: Exercise? {
        exerciseQueue.indices.contains(currentExerciseIndex) ? exerciseQueue[currentExerciseIndex] : nil
    }

    var phase: ExercisePhase {
        restStartDate == nil ? .active : .resting
    }

    var isResting: Bool {
        restStartDate != nil
    }

    /// The 1-based number of the set the user is working on (or resting before).
    var currentSetNumber: Int {
        currentSets.count + 1
    }

    var remainingExercises: [Exercise] {
        Array(exerciseQueue.dropFirst(currentExerciseIndex + 1))
    }

    /// The current exercise can be swapped only before any of its sets are logged.
    var canSwap: Bool {
        !isComplete && !isResting && currentSets.isEmpty && !remainingExercises.isEmpty
    }

    var lastLoggedWeight: Double? {
        currentSets.last?.weight
    }

    /// Completed exercises plus the in-progress exercise's logged sets, if it has any.
    var exercisesToSave: [PerformedExercise] {
        guard !isComplete, let exercise = currentExercise, !currentSets.isEmpty else {
            return completedExercises
        }
        return completedExercises + [PerformedExercise(id: currentExerciseID, exercise: exercise, sets: currentSets)]
    }

    var loggedSetCount: Int {
        exercisesToSave.reduce(0) { $0 + $1.sets.count }
    }

    // MARK: - Public Methods
    /// Logs a set for the current exercise, then starts a rest, moves to the next
    /// exercise, or completes the workout. Returns `nil` if no set can be logged.
    mutating func logSet(reps: Int, weight: Double, at date: Date) -> LogSetOutcome? {
        guard !isComplete, !isResting, let exercise = currentExercise else { return nil }

        currentSets.append(
            PerformedSet(id: UUID(), set: exercise.setData, reps: reps, weight: weight, restTime: 0)
        )

        if currentSets.count < exercise.numberOfSets {
            restStartDate = date
            return .resting
        }

        completeCurrentExercise()
        return isComplete ? .workoutComplete : .nextExercise
    }

    /// Ends the current rest and records its duration on the last logged set.
    mutating func finishRest(at date: Date) {
        guard let restStartDate, !currentSets.isEmpty else { return }
        currentSets[currentSets.count - 1].restTime = max(0, date.timeIntervalSince(restStartDate))
        self.restStartDate = nil
    }

    func restRemaining(at date: Date) -> TimeInterval {
        guard let restStartDate, let exercise = currentExercise else { return 0 }
        return max(0, exercise.restBetweenSets - date.timeIntervalSince(restStartDate))
    }

    func restProgress(at date: Date) -> Double {
        guard let restStartDate, let exercise = currentExercise, exercise.restBetweenSets > 0 else { return 1 }
        return min(1, max(0, date.timeIntervalSince(restStartDate) / exercise.restBetweenSets))
    }

    /// Moves `chosen` (a later exercise in the queue) into the current slot; the
    /// current exercise becomes the next one.
    mutating func swapCurrentExercise(with chosen: Exercise) {
        guard canSwap,
              let chosenIndex = exerciseQueue[(currentExerciseIndex + 1)...].firstIndex(where: { $0.id == chosen.id })
        else { return }

        let exercise = exerciseQueue.remove(at: chosenIndex)
        exerciseQueue.insert(exercise, at: currentExerciseIndex)
        currentExerciseID = UUID()
    }

    // MARK: - Private Methods
    private mutating func completeCurrentExercise() {
        guard let exercise = currentExercise else { return }

        completedExercises.append(PerformedExercise(id: currentExerciseID, exercise: exercise, sets: currentSets))
        currentSets = []
        restStartDate = nil

        if currentExerciseIndex + 1 < exerciseQueue.count {
            currentExerciseIndex += 1
            currentExerciseID = UUID()
        } else {
            isComplete = true
        }
    }
}
