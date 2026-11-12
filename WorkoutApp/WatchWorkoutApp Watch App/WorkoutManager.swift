//
//  WorkoutManager.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 11.05.2023.
//

import Foundation
import HealthKit
import Combine
import WatchKit

@MainActor @Observable
class WorkoutManager: NSObject {

    // MARK: - Properties
    @ObservationIgnored let healthStore = HKHealthStore()
    @ObservationIgnored private var session: HKWorkoutSession?
    @ObservationIgnored private var builder: HKLiveWorkoutBuilder?
    @ObservationIgnored let phoneCommunicator: any PhoneCommunicatorProtocol
    @ObservationIgnored private let progressStore: any WorkoutProgressStoring
    @ObservationIgnored private var templatesTask: Task<Void, Never>?
    @ObservationIgnored private var restTask: Task<Void, Never>?
    @ObservationIgnored private var isFinalizing = false
    @ObservationIgnored private var recoveryTask: Task<Void, Never>?
    private static let startFailureMessage = "Check that Health access is allowed for this app, then try again."
    @ObservationIgnored private let logger = CustomLogger(
        subsystem: "com.raulpele.WatchWorkoutApp",
        category: "WorkoutManager"
    )

    private(set) var lifecycle: WorkoutLifecycle = .idle
    private(set) var running = false
    private(set) var isLoading = false
    private(set) var loadError: Error?

    // MARK: - Workout exercises
    var workoutTemplates = [Workout]()
    /// Progress of the active workout. Owned here, not by a view, so every end path
    /// can save the logged exercises. Persisted on every change for crash recovery.
    private(set) var progress: WorkoutProgress? {
        didSet {
            guard progress != oldValue else { return }
            if let progress {
                progressStore.save(progress)
            } else {
                progressStore.clear()
            }
        }
    }
    /// Saved progress whose HealthKit session couldn't be recovered (e.g. the app was
    /// force-quit). The user can resume it in a new session or discard it.
    private(set) var interruptedProgress: WorkoutProgress?
    /// Exercises captured when the workout ended; these are what get sent to the phone.
    private(set) var exercisesToSave: [PerformedExercise] = []

    // MARK: - Workout metrics
    private(set) var workout: HKWorkout?
    private(set) var heartRate: Double = 0
    private(set) var activeEnergyBurned: Double = 0
    private(set) var averageHeartRate: Double = 0

    // MARK: - Initializers
    init(
        phoneCommunicator: any PhoneCommunicatorProtocol = PhoneCommunicator(),
        progressStore: any WorkoutProgressStoring = FileWorkoutProgressStore()
    ) {
        self.phoneCommunicator = phoneCommunicator
        self.progressStore = progressStore
        super.init()
        subscribeToTemplates()
    }

    // MARK: - Computed Properties
    var isShowingSummary: Bool {
        lifecycle.isShowingSummary
    }

    var workoutStartDate: Date? {
        builder?.startDate
    }

    var isSessionPaused: Bool {
        session?.state == .paused
    }

    func elapsedTime(at date: Date) -> TimeInterval {
        builder?.elapsedTime(at: date) ?? 0
    }

    // MARK: - Public Methods
    func requestAuthorization() async {
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        let typesToRead: Set<HKObjectType> = [
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.basalEnergyBurned),
            HKObjectType.activitySummaryType()
        ]

        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
        } catch {
            logger.error("Error while requesting authorization: \(error.localizedDescription)")
        }
    }

    func updateMetrics(for statistics: HKStatistics?) {
        guard let statistics else { return }

        switch statistics.quantityType {
        case HKQuantityType(.heartRate):
            let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
            heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0

        case HKQuantityType(.activeEnergyBurned):
            activeEnergyBurned = statistics.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
        default:
            return
        }
    }

    func togglePauseWorkout() {
        running ? pauseWorkout() : resumeWorkout()
    }

    func pauseWorkout() {
        session?.pause()
    }

    func resumeWorkout() {
        session?.resume()
    }

    /// The single end path, used by Controls and the final set. Captures the logged
    /// exercises and shows the summary right away; saving finishes in `finalize`.
    func endWorkout() {
        guard lifecycle.isInProgress else { return }
        beginSaving()

        if let session, session.state != .ended {
            session.end() // finalize runs when the session reports .ended
        } else {
            Task { await finalize(endDate: .now) }
        }
    }

    /// Closes the summary once saving has finished or failed, and resets for the next workout.
    func dismissSummary() {
        switch lifecycle {
        case .finished, .saveFailed:
            resetWorkout()
        case .idle, .starting, .failedToStart, .active, .saving:
            return
        }
    }

    /// Abandons a workout that failed to start, returning to the workout list.
    func discardWorkout() {
        guard case .failedToStart = lifecycle else { return }
        resetWorkout()
    }

    // MARK: - Exercise Tracking
    /// Logs a set for the current exercise and ends the workout after its final set.
    func logSet(reps: Int, weight: Double) {
        guard lifecycle.isInProgress,
              let outcome = progress?.logSet(reps: reps, weight: weight, at: .now) else { return }

        switch outcome {
        case .resting:
            if session?.state == .paused {
                progress?.pauseRest(at: .now)
            }
            scheduleRestEnd()
        case .nextExercise:
            break
        case .workoutComplete:
            endWorkout()
        }
    }

    /// Ends the rest (when skipped or when its time is up) and signals the next set.
    func finishRest() {
        guard lifecycle.isInProgress, progress?.isResting == true else { return }
        cancelRestTimer()
        progress?.finishRest(at: .now)
        WKInterfaceDevice.current().play(.start)
    }

    func swapCurrentExercise(with exercise: Exercise) {
        guard lifecycle.isInProgress else { return }
        progress?.swapCurrentExercise(with: exercise)
    }

    func loadWorkoutTemplates() async {
        isLoading = true
        loadError = nil
        do {
            let templates = try await phoneCommunicator.requestWorkoutTemplates()
            workoutTemplates = templates
        } catch {
            logger.error("Error while loading workouts on watch: \(error.localizedDescription)")
            if workoutTemplates.isEmpty {
                loadError = error
            }
        }
        isLoading = false
    }

    /// Starts a HealthKit session for `template`, keeping any progress already logged
    /// (e.g. when retrying). Safe to call repeatedly, such as when the view's `.task`
    /// re-runs: it does nothing unless idle or retrying after a failed start.
    func startWorkout(template: Workout) async {
        // Let a launch-time recovery finish first; it may restore this or another workout.
        await recoveryTask?.value

        switch lifecycle {
        case .idle, .failedToStart:
            break
        case .starting, .active, .saving, .finished, .saveFailed:
            return
        }
        guard session == nil else { return }
        if let progress, progress.template.id != template.id { return }

        lifecycle = .starting
        let startDate = Date.now
        if progress == nil {
            progress = WorkoutProgress(template: template, startDate: startDate)
        }

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor

        let newSession: HKWorkoutSession
        do {
            newSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        } catch {
            logger.error("Error while creating session: \(error.localizedDescription)")
            lifecycle = .failedToStart(message: Self.startFailureMessage)
            return
        }

        let newBuilder = newSession.associatedWorkoutBuilder()
        newBuilder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
        attach(session: newSession, builder: newBuilder)
        newSession.startActivity(with: startDate)

        do {
            try await newBuilder.beginCollection(at: startDate)
            guard lifecycle == .starting else { return }
            lifecycle = .active
            WKInterfaceDevice.current().play(.start)
        } catch {
            logger.error("Error in builder's beginCollection method: \(error.localizedDescription)")
            guard lifecycle == .starting else { return } // ended while starting; the end path owns it
            detachSession()
            newSession.end()
            lifecycle = .failedToStart(message: Self.startFailureMessage)
        }
    }

    // MARK: - Private Methods
    private func attach(session: HKWorkoutSession, builder: HKLiveWorkoutBuilder) {
        session.delegate = self
        builder.delegate = self
        self.session = session
        self.builder = builder
    }

    private func detachSession() {
        session?.delegate = nil
        builder?.delegate = nil
        session = nil
        builder = nil
    }

    /// Ends the rest on time from a task rather than a view's timeline, so it fires with
    /// the screen off (the active workout session keeps the app running).
    private func scheduleRestEnd() {
        cancelRestTimer()
        guard let progress, progress.isResting, !progress.isRestPaused else { return }

        let remaining = progress.restRemaining(at: .now)
        restTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(remaining))
            } catch {
                return // cancelled: rest skipped, workout paused or ended
            }
            self?.finishRest()
        }
    }

    private func cancelRestTimer() {
        restTask?.cancel()
        restTask = nil
    }

    private func resetWorkout() {
        cancelRestTimer()
        detachSession()
        workout = nil
        progress = nil
        exercisesToSave = []
        isFinalizing = false
        lifecycle = .idle
        running = false

        activeEnergyBurned = 0
        averageHeartRate = 0
        heartRate = 0
    }

    private func subscribeToTemplates() {
        let templates = phoneCommunicator.templatesPublisher.values
        templatesTask = Task { [weak self] in
            for await value in templates {
                self?.workoutTemplates = value
            }
        }
    }

    private func beginSaving() {
        cancelRestTimer()
        exercisesToSave = progress?.exercisesToSave ?? []
        lifecycle = .saving
    }

    /// Saves the workout to HealthKit and sends the logged exercises to the phone.
    /// Always leaves the summary in `.finished` or `.saveFailed` so it can be dismissed.
    private func finalize(endDate: Date) async {
        guard lifecycle == .saving, !isFinalizing else { return }
        isFinalizing = true

        var savedWorkout: HKWorkout?
        var didSave = false
        if let builder {
            do {
                try await builder.endCollection(at: endDate)
                savedWorkout = try await builder.finishWorkout()
                didSave = true
            } catch {
                logger.error("Error finalizing workout: \(error.localizedDescription)")
            }
        } else {
            logger.error("Cannot save workout: no workout builder")
        }

        workout = savedWorkout
        sendWorkoutSession(workout: savedWorkout, endDate: endDate)
        progressStore.clear() // sent (or nothing to send); don't offer it for recovery
        lifecycle = didSave ? .finished : .saveFailed(message: "This workout couldn't be saved to Apple Health.")
    }

    /// Sends the session to the phone even if the HealthKit save failed, so logged sets aren't lost.
    private func sendWorkoutSession(workout: HKWorkout?, endDate: Date) {
        guard let progress else { return }
        guard workout != nil || !exercisesToSave.isEmpty else {
            logger.info("No workout saved and no sets logged; nothing to send to phone")
            return
        }

        let startDate = workout?.startDate ?? progress.startDate
        var workoutSession = WorkoutSession(
            id: workout?.uuid ?? UUID(),
            workoutTemplate: progress.template,
            performedExercises: exercisesToSave
        )
        workoutSession.title = startDate.toMMMdd()
        workoutSession.startDate = startDate
        workoutSession.endDate = endDate
        workoutSession.duration = workout?.duration ?? endDate.timeIntervalSince(startDate)
        workoutSession.activeCalories = workout?.activeEnergyBurned
        workoutSession.averageHeartRate = workout?.averageHeartRate
        workoutSession.totalCalories = workout?.totalCalories

        logger.info("Sent workout session with id: \(workoutSession.id) and \(exercisesToSave.count) exercises to phone")
        phoneCommunicator.send(workoutSession: workoutSession)
    }
}

// MARK: - Previews
#if DEBUG
extension WorkoutManager {
    /// A manager with an in-progress workout and no HealthKit session, for previews.
    static func preview(progress: WorkoutProgress?) -> WorkoutManager {
        let workoutManager = WorkoutManager(
            phoneCommunicator: MockedPhoneCommunicator(),
            progressStore: InMemoryWorkoutProgressStore()
        )
        workoutManager.progress = progress
        workoutManager.lifecycle = progress == nil ? .idle : .active
        return workoutManager
    }
}
#endif

// MARK: - Recovery
extension WorkoutManager {

    /// Called at launch: tries to recover a session only if progress was saved.
    func recoverActiveWorkoutIfNeeded() async {
        guard progressStore.load() != nil else { return }
        await recoverActiveWorkout()
    }

    /// Re-attaches to a workout session that survived an app crash and restores the
    /// logged progress. If no session is left (e.g. after a force-quit) but progress
    /// was saved, it is offered through `interruptedProgress` instead.
    func recoverActiveWorkout() async {
        if let recoveryTask {
            await recoveryTask.value
            return
        }
        guard lifecycle == .idle, session == nil else { return }

        let task = Task { await performRecovery() }
        recoveryTask = task
        await task.value
        recoveryTask = nil
    }

    private func performRecovery() async {
        let savedProgress = progressStore.load()
        let recoveredSession: HKWorkoutSession?
        do {
            recoveredSession = try await healthStore.recoverActiveWorkoutSession()
        } catch {
            logger.error("Error recovering workout session: \(error.localizedDescription)")
            recoveredSession = nil
        }

        guard let recoveredSession else {
            if let savedProgress, savedProgress.loggedSetCount > 0 {
                interruptedProgress = savedProgress
            } else {
                progressStore.clear() // nothing worth offering
            }
            return
        }

        logger.info("Recovered workout session in state \(recoveredSession.state.rawValue)")
        let recoveredBuilder = recoveredSession.associatedWorkoutBuilder()
        recoveredBuilder.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: recoveredSession.workoutConfiguration
        )
        attach(session: recoveredSession, builder: recoveredBuilder)
        interruptedProgress = nil
        progress = savedProgress
        running = recoveredSession.state == .running
        lifecycle = .active

        switch recoveredSession.state {
        case .running where savedProgress != nil:
            scheduleRestEnd() // a rest that ran out while the app was down ends now
        case .paused where savedProgress != nil:
            progress?.pauseRest(at: .now)
        default:
            endWorkout() // nothing to continue; save what HealthKit recorded
        }
    }

    /// Continues an interrupted workout. `WorkoutsFlowCoordinator` then shows
    /// `ActiveWorkoutView`, whose `.task` starts a new session with this progress.
    func resumeInterruptedWorkout(_ interrupted: WorkoutProgress) {
        guard lifecycle == .idle, session == nil else { return }
        interruptedProgress = nil
        progress = interrupted
    }

    func discardInterruptedWorkout() {
        interruptedProgress = nil
        progressStore.clear()
    }

    /// Hides the prompt but keeps the saved progress, so it is offered again next launch.
    func dismissInterruptedWorkoutPrompt() {
        interruptedProgress = nil
    }
}

// MARK: - Session State
extension WorkoutManager {

    fileprivate func handleStateChange(of workoutSession: HKWorkoutSession, to state: HKWorkoutSessionState, date: Date) async {
        guard workoutSession === session else { return }
        running = state == .running

        switch state {
        case .paused:
            cancelRestTimer()
            progress?.pauseRest(at: date)
        case .running:
            progress?.resumeRest(at: date)
            scheduleRestEnd()
        case .ended:
            if lifecycle.isInProgress {
                beginSaving() // the system ended the session, not the user
            }
            await finalize(endDate: date)
        default:
            break
        }
    }
}

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {

    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        Task { @MainActor in
            await self.handleStateChange(of: workoutSession, to: toState, date: date)
        }
    }

    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        logger.error("Workout session failed with error: \(error.localizedDescription)")
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
    }

    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                continue
            }

            let statistics = workoutBuilder.statistics(for: quantityType)
            Task { @MainActor in
                updateMetrics(for: statistics)
            }
        }
    }
}
