//
//  ExerciseTrackingViewModel.swift
//  WatchWorkoutApp Watch App
//

import Foundation
import WatchKit

/// Screen state for exercise tracking. Workout progress itself lives in
/// `WorkoutManager.progress`; this view model only holds input and sheet state.
@MainActor @Observable
final class ExerciseTrackingViewModel {

    // MARK: - Properties
    var currentReps: Double = 0
    var currentWeight: Double = 0
    var showingLogSheet = false
    var showingSwapSheet = false
    @ObservationIgnored private var pendingSet: (reps: Int, weight: Double)?
    private let workoutManager: WorkoutManager

    // MARK: - Computed Properties
    var exercise: Exercise? {
        progress?.currentExercise
    }

    var phase: ExercisePhase {
        progress?.phase ?? .active
    }

    var currentSet: Int {
        progress?.currentSetNumber ?? 1
    }

    var totalSets: Int {
        exercise?.numberOfSets ?? 0
    }

    var restStartDate: Date? {
        progress?.restStartDate
    }

    var canSwap: Bool {
        progress?.canSwap ?? false
    }

    var remainingExercises: [Exercise] {
        progress?.remainingExercises ?? []
    }

    private var progress: WorkoutProgress? {
        workoutManager.progress
    }

    // MARK: - Initializers
    init(workoutManager: WorkoutManager) {
        self.workoutManager = workoutManager
    }

    // MARK: - Public Methods
    func openLogSheet() {
        guard let exercise, phase == .active else { return }
        currentReps = Double(exercise.setData.reps)
        currentWeight = progress?.lastLoggedWeight ?? 0
        showingLogSheet = true
    }

    /// Queues the set and closes the sheet. The set is logged in `logSheetDidDismiss()`
    /// so the summary sheet, shown after the final set, never presents mid-dismissal.
    func saveSet() {
        pendingSet = (Int(currentReps), currentWeight)
        showingLogSheet = false
    }

    func logSheetDidDismiss() {
        guard let pendingSet else { return }
        self.pendingSet = nil
        WKInterfaceDevice.current().play(.success)
        workoutManager.logSet(reps: pendingSet.reps, weight: pendingSet.weight)
    }

    func completeRest() {
        workoutManager.finishRest()
    }

    func skipRest() {
        workoutManager.finishRest()
    }

    func swap(to exercise: Exercise) {
        showingSwapSheet = false
        workoutManager.swapCurrentExercise(with: exercise)
    }

    func restRemaining(at date: Date) -> TimeInterval {
        progress?.restRemaining(at: date) ?? 0
    }

    func restProgress(at date: Date) -> Double {
        progress?.restProgress(at: date) ?? 1
    }
}
