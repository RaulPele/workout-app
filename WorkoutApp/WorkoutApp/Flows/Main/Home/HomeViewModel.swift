//
// HomeViewModel.swift
// WorkoutApp
//
// Created by Raul Pele on 02.05.2023.
//
//

import Foundation

extension Home {
    
    class ViewModel: ObservableObject {
        
        @Published var isLoading: Bool = false
        @Published var workouts: [Workout] = Workout.mockedSet
        
        private let workoutRepository: any WorkoutRepository
        private let healthKitManager: HealthKitManager
        
        var onWorkoutTapped: ((_ for: Workout) -> Void)?
        
        init(workoutRepository: any WorkoutRepository,
             healthKitManager: HealthKitManager) {
            self.workoutRepository = workoutRepository
            self.healthKitManager = healthKitManager
        }
        
        func handleOnAppear() {
            requestHealthKitPermissions() //TODO: find a better place to request permissions
            loadWorkouts()
        }
        
        private func requestHealthKitPermissions() {
            Task(priority: .high) {
                try await healthKitManager.requestPermissions(fromWatch: false)
            }
//            healthKitManager.requestPermissions { error in
//                print("ERROR: \(error?.localizedDescription)")
//            }
        }
        
        func loadWorkouts() {
            isLoading = true
            
            Task(priority: .background) { @MainActor in
                
                do {
                    let workouts = try await workoutRepository.getAll()
                    self.workouts = workouts
                } catch {
                    print("Error while loading workouts: \(error.localizedDescription)")
                }
                
                isLoading = false
            }
        }
        
        func handleWorkoutTapped(for workout: Workout) {
            onWorkoutTapped?(workout)
        }
        
    }
}
