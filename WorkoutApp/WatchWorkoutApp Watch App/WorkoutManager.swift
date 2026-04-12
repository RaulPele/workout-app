//
//  WorkoutManager.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 11.05.2023.
//

import Foundation
import HealthKit
import Combine

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
    private(set) var activeWorkoutTemplate: Workout?
    private(set) var workoutSession: WorkoutSession?

    // MARK: - Internal State
    private var pendingPerformedExercises: [PerformedExercise] = []

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

    func endWorkout() {
        session?.end()
    }

    func finishWorkout(performedExercises: [PerformedExercise]) {
        self.pendingPerformedExercises = performedExercises
        endWorkout()
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
        activeWorkoutTemplate = template

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

        let startDate = Date()
        session?.startActivity(with: startDate)

        do {
            try await builder?.beginCollection(at: startDate)

            workoutSession = WorkoutSession(
                id: UUID(),
                workoutTemplate: template,
                performedExercises: []
            )
        } catch {
            logger.error("Error in builder's beginCollection method: \(error.localizedDescription)")
        }
    }

    // MARK: - Private Methods
    private func resetWorkout() {
        activeWorkoutTemplate = nil
        builder = nil
        session = nil
        workout = nil
        workoutSession = nil
        pendingPerformedExercises = []

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

            workoutSession?.id = workout?.uuid ?? .init()
            workoutSession?.activeCalories = workout?.activeEnergyBurned
            workoutSession?.averageHeartRate = workout?.averageHeartRate
            workoutSession?.totalCalories = workout?.totalCalories
            workoutSession?.duration = workout?.duration
            workoutSession?.performedExercises = pendingPerformedExercises
            workoutSession?.endDate = endDate
            workoutSession?.startDate = workout?.startDate
            workoutSession?.title = workout?.startDate.toMMMdd()

            guard let wkSession = workoutSession else { return }
            logger.info("Sent workout session with id: \(wkSession.id) to phone")
            phoneCommunicator.send(workoutSession: wkSession)

            showingSummaryView = true
        } catch {
            logger.error("Error finalizing workout: \(error.localizedDescription)")
        }
    }
}

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
