//
//  WorkoutManager.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 11.05.2023.
//

import Foundation
import HealthKit

class WorkoutManager: NSObject, ObservableObject {
    
    var selectedWorkoutTemplate: Workout? {
        didSet {
            guard let selectedWorkoutTemplate else { return }
            startWorkout(workoutType: .traditionalStrengthTraining)
        }
    }
    
    @Published var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }
    
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    private let phoneCommunicator = PhoneCommunicator()
    
    @Published var running = false
    @Published var isLoading = false //TODO: move
    
    // MARK: - Workout exercises
    @Published var workoutTemplates = [Workout]()
    var workoutSession: WorkoutSession?
    @Published var performedExercises: [PerformedExercise] = []
    
    // MARK: - Workout metrics
    @Published var workout: HKWorkout?
    @Published var heartRate: Double = 0
    @Published var activeEnergyBurned: Double = 0
    @Published var averageHeartRate: Double = 0
    
    var remainingExercises: [Exercise] {
        guard let selectedWorkoutTemplate else { return []}
        return selectedWorkoutTemplate.exercises.filter { ex in !performedExercises.contains { $0.exercise.id == ex.id}}
    }
    
    func requestAuthorization(onFinished: @escaping () -> Void = { }) {
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!,
            HKObjectType.activitySummaryType()
        ]

        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            // Handle error.
            if let error {
                print("Error while requesting authorization: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    onFinished()
                }
            }
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
            //Workout has started
            if let error = error {
                print("Error in builder's beginCollection method: \(error.localizedDescription)")
            } else if success {
                self?.workoutSession = WorkoutSession(
                    id: UUID(),
                    workoutTemplate: self?.selectedWorkoutTemplate ?? .mockedWorkoutTemplate,
                    performedExercises: []
                )
            }
            
        }
    }
    
    func updateMetrics(for statistics: HKStatistics?) {
        guard let statistics = statistics else { return }
        
        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType(.heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute()) //TODO: add as an extension
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                
            case HKQuantityType(.activeEnergyBurned):
                self.activeEnergyBurned = statistics.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                print(self.activeEnergyBurned)
            default:
                return
            }
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
    
    func loadWorkoutTemplates() {
        isLoading = true
        do {
            try phoneCommunicator.requestWorkoutTemplates { [weak self] templates in
                DispatchQueue.main.async {
                    self?.workoutTemplates = templates
                    self?.isLoading = false
                }
            }
        } catch {
            print("ERROR WHILE LOADING WORKOUTS ON WATCH: \(error.localizedDescription)")
            isLoading = false
        }
    }
}

//MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            self.running = toState == .running
        }
        
        if toState == .ended {
            builder?.endCollection(withEnd: date) { success, error in
                self.builder?.finishWorkout { workout, error in
                    DispatchQueue.main.async {
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
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        
    }
}

extension Date {
    func toMMMdd() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, HH:mm"
        return dateFormatter.string(from: self)
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {

    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return
            }

            let statistics = workoutBuilder.statistics(for: quantityType)
            updateMetrics(for: statistics)
        }
    }
}
