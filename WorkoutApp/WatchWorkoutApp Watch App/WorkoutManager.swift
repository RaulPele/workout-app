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
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored private let logger = CustomLogger(
        subsystem: "com.raulpele.WatchWorkoutApp",
        category: "WorkoutManager"
    )

    private(set) var running = false
    private(set) var isLoading = false
    private(set) var loadError: Error?
    var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }

    // MARK: - Workout exercises
    var workoutTemplates = [Workout]()
    /// Progress of the active workout. Owned here, not by a view, so every end path
    /// can save the logged exercises.
    private(set) var progress: WorkoutProgress?

    // MARK: - Workout metrics
    private(set) var workout: HKWorkout?
    private(set) var heartRate: Double = 0
    private(set) var activeEnergyBurned: Double = 0
    private(set) var averageHeartRate: Double = 0

    // MARK: - Initializers
    init(phoneCommunicator: any PhoneCommunicatorProtocol = PhoneCommunicator()) {
        self.phoneCommunicator = phoneCommunicator
        super.init()
        subscribeToTemplates()
    }

    // MARK: - Computed Properties
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

    /// Ends the workout. Every end (Controls, the last set, or the system ending the
    /// session) saves `progress.exercisesToSave` once the session reports `.ended`.
    func endWorkout() {
        session?.end()
    }

    // MARK: - Exercise Tracking
    /// Logs a set for the current exercise and ends the workout after its final set.
    func logSet(reps: Int, weight: Double) {
        guard let outcome = progress?.logSet(reps: reps, weight: weight, at: .now) else { return }
        if outcome == .workoutComplete {
            endWorkout()
        }
    }

    func finishRest() {
        guard progress?.isResting == true else { return }
        progress?.finishRest(at: .now)
        WKInterfaceDevice.current().play(.start)
    }

    func swapCurrentExercise(with exercise: Exercise) {
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

    func startWorkout(template: Workout) async {
        let startDate = Date()
        progress = WorkoutProgress(template: template, startDate: startDate)

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            logger.error("Error while creating session: \(error.localizedDescription)")
            return
        }

        session?.delegate = self
        builder?.delegate = self

        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

        session?.startActivity(with: startDate)

        do {
            try await builder?.beginCollection(at: startDate)
        } catch {
            logger.error("Error in builder's beginCollection method: \(error.localizedDescription)")
        }
    }

    // MARK: - Private Methods
    private func resetWorkout() {
        builder = nil
        session = nil
        workout = nil
        progress = nil

        activeEnergyBurned = 0
        averageHeartRate = 0
        heartRate = 0
    }

    private func subscribeToTemplates() {
        phoneCommunicator
            .templatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] templates in
                self?.workoutTemplates = templates
            }
            .store(in: &cancellables)
    }

    private func finalizeWorkout(endDate: Date) async {
        do {
            try await builder?.endCollection(at: endDate)

            let workout = try await builder?.finishWorkout()

            self.workout = workout

            if let progress {
                var workoutSession = WorkoutSession(
                    id: workout?.uuid ?? UUID(),
                    workoutTemplate: progress.template,
                    performedExercises: progress.exercisesToSave
                )
                workoutSession.activeCalories = workout?.activeEnergyBurned
                workoutSession.averageHeartRate = workout?.averageHeartRate
                workoutSession.totalCalories = workout?.totalCalories
                workoutSession.duration = workout?.duration
                workoutSession.endDate = endDate
                workoutSession.startDate = workout?.startDate
                workoutSession.title = workout?.startDate.toMMMdd()

                logger.info("Sent workout session with id: \(workoutSession.id) and \(workoutSession.performedExercises.count) exercises to phone")
                phoneCommunicator.send(workoutSession: workoutSession)
            }

            showingSummaryView = true
        } catch {
            logger.error("Error finalizing workout: \(error.localizedDescription)")
        }
    }
}

// MARK: - Previews
#if DEBUG
extension WorkoutManager {
    /// A manager with an in-progress workout and no HealthKit session, for previews.
    static func preview(progress: WorkoutProgress?) -> WorkoutManager {
        let workoutManager = WorkoutManager(phoneCommunicator: MockedPhoneCommunicator())
        workoutManager.progress = progress
        return workoutManager
    }
}
#endif

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {

    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        Task { @MainActor in
            self.running = toState == .running

            if toState == .ended {
                await self.finalizeWorkout(endDate: date)
            }
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
