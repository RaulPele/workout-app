//
//  ExerciseTrackingViewModel.swift
//  WatchWorkoutApp Watch App
//

import Foundation
import WatchKit

// MARK: - ExercisePhase
enum ExercisePhase {
    case active
    case resting
    case exerciseComplete
}

// MARK: - ExerciseTrackingViewModel
@MainActor @Observable
final class ExerciseTrackingViewModel {

    // MARK: - Constants
    private enum Constants {
        static let confirmationDuration: TimeInterval = 1.5
        static let metricRotationInterval: TimeInterval = 3.0
    }

    // MARK: - Properties
    let exercise: Exercise
    private(set) var phase: ExercisePhase = .active
    private(set) var currentSet: Int = 1
    var currentReps: Double
    var currentWeight: Double
    private(set) var performedSets: [PerformedSet] = []
    private(set) var restStartDate: Date?
    var isRepsFocused: Bool = true
    var showingLogSheet: Bool = false
    var showingSwapSheet: Bool = false

    var restDuration: TimeInterval {
        exercise.restBetweenSets
    }

    var totalSets: Int {
        exercise.numberOfSets
    }

    var isLastSet: Bool {
        currentSet >= exercise.numberOfSets
    }

    var totalRepsPerformed: Int {
        performedSets.reduce(0) { $0 + $1.reps }
    }

    // MARK: - Initializers
    init(exercise: Exercise) {
        self.exercise = exercise
        self.currentReps = Double(exercise.setData.reps)
        self.currentWeight = 0
    }

    #if DEBUG
    /// Preview-only initializer for configuring specific states.
    init(exercise: Exercise, phase: ExercisePhase, currentSet: Int, performedSets: [PerformedSet] = [], restStartDate: Date? = nil) {
        self.exercise = exercise
        self.currentReps = Double(exercise.setData.reps)
        self.currentWeight = 0
        self.phase = phase
        self.currentSet = currentSet
        self.performedSets = performedSets
        self.restStartDate = restStartDate
    }
    #endif

    // MARK: - Public Methods
    func saveSet() {
        let performedSet = PerformedSet(
            id: UUID(),
            set: exercise.setData,
            reps: Int(currentReps),
            weight: currentWeight,
            restTime: 0
        )

        performedSets.append(performedSet)
        showingLogSheet = false
        WKInterfaceDevice.current().play(.success)

        if isLastSet {
            phase = .exerciseComplete
        } else {
            startRest()
        }
    }

    func restRemaining(at date: Date) -> TimeInterval {
        guard let restStartDate else { return 0 }
        return max(0, restDuration - date.timeIntervalSince(restStartDate))
    }

    func restProgress(at date: Date) -> Double {
        guard restDuration > 0 else { return 1 }
        let elapsed = date.timeIntervalSince(restStartDate ?? date)
        return min(1, elapsed / restDuration)
    }

    func completeRest() {
        let actualRestTime = Date.now.timeIntervalSince(restStartDate ?? Date.now)
        if var lastSet = performedSets.last {
            performedSets.removeLast()
            lastSet = PerformedSet(
                id: lastSet.id,
                set: lastSet.set,
                reps: lastSet.reps,
                weight: lastSet.weight,
                restTime: actualRestTime
            )
            performedSets.append(lastSet)
        }

        restStartDate = nil
        currentSet += 1
        currentReps = Double(exercise.setData.reps)
        WKInterfaceDevice.current().play(.start)
        phase = .active
    }

    func skipRest() {
        completeRest()
    }

    func finishExercise() -> PerformedExercise {
        PerformedExercise(
            id: UUID(),
            exercise: exercise,
            sets: performedSets
        )
    }

    // MARK: - Private Methods
    private func startRest() {
        restStartDate = Date.now
        phase = .resting
    }
}
