//
//  WorkoutManager.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 11.05.2023.
//

import Foundation
import HealthKit

@MainActor @Observable
class WorkoutManager: NSObject {

    var selectedWorkoutTemplate: Workout? {
        didSet {
            guard let selectedWorkoutTemplate else { return }
            startWorkout(workoutType: .traditionalStrengthTraining)
        }
    }

    var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }

    @ObservationIgnored let healthStore = HKHealthStore()
    @ObservationIgnored var session: HKWorkoutSession?
    @ObservationIgnored var builder: HKLiveWorkoutBuilder?
    @ObservationIgnored private let phoneCommunicator = PhoneCommunicator()

    var running = false
    var isLoading = false

    // MARK: - Workout exercises
    var workoutTemplates = [Workout]()
    var workoutSession: WorkoutSession?
    var performedExercises: [PerformedExercise] = []

    // MARK: - Workout metrics
    var workout: HKWorkout?
    var heartRate: Double = 0
    var activeEnergyBurned: Double = 0
    var averageHeartRate: Double = 0

    var remainingExercises: [Exercise] {
        guard let selectedWorkoutTemplate else { return [] }
        return selectedWorkoutTemplate.exercises.filter { ex in !performedExercises.contains { $0.exercise.id == ex.id } }
    }

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
            print("Error while requesting authorization: \(error.localizedDescription)")
        }
    }

    func startWorkout(workoutType: HKWorkoutActivityType) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = .indoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            print("Error while creating session: \(error.localizedDescription)")
            return
        }

        session?.delegate = self
        builder?.delegate = self

        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

        workoutSession = .mocked1 //TODO: change

        let startDate = Date()
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { [weak self] success, error in
            if let error {
                print("Error in builder's beginCollection method: \(error.localizedDescription)")
            } else if success {
                Task { @MainActor in
                    self?.workoutSession = WorkoutSession(
                        id: UUID(),
                        workoutTemplate: self?.selectedWorkoutTemplate ?? .mockedWorkoutTemplate,
                        performedExercises: []
                    )
                }
            }
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

    func resetWorkout() {
        selectedWorkoutTemplate = nil
        builder = nil
        session = nil
        workout = nil
        workoutSession = nil

        activeEnergyBurned = 0
        averageHeartRate = 0
        heartRate = 0
        performedExercises = []
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
        showingSummaryView = true
    }

    func loadWorkoutTemplates() async {
        isLoading = true
        do {
            let templates = try await phoneCommunicator.requestWorkoutTemplates()
            workoutTemplates = templates
        } catch {
            print("ERROR WHILE LOADING WORKOUTS ON WATCH: \(error.localizedDescription)")
        }
        isLoading = false
    }
}

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {

    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        Task { @MainActor in
            self.running = toState == .running

            if toState == .ended {
                self.builder?.endCollection(withEnd: date) { success, error in
                    self.builder?.finishWorkout { workout, error in
                        Task { @MainActor in
                            self.workout = workout

                            self.workoutSession?.id = workout?.uuid ?? .init()
                            self.workoutSession?.activeCalories = workout?.activeEnergyBurned
                            self.workoutSession?.averageHeartRate = workout?.averageHeartRate
                            self.workoutSession?.totalCalories = workout?.totalCalories
                            self.workoutSession?.duration = workout?.duration
                            self.workoutSession?.performedExercises = self.performedExercises
                            self.workoutSession?.endDate = date
                            self.workoutSession?.startDate = workout?.startDate
                            self.workoutSession?.title = workout?.startDate.toMMMdd()

                            guard let wkSession = self.workoutSession else { return }
                            print("Sent workout session with id: \(wkSession.id) to PHONE")
                            try? self.phoneCommunicator.send(workoutSession: wkSession)
                        }
                    }
                }
            }
        }
    }

    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
    }

    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return
            }

            let statistics = workoutBuilder.statistics(for: quantityType)
            Task { @MainActor in
                updateMetrics(for: statistics)
            }
        }
    }
}
