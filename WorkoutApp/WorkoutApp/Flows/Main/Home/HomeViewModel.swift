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
        @Published var workouts: [WorkoutSession] = []
        
        private let workoutRepository: any WorkoutSessionRepository
        private let healthKitManager: HealthKitManager
        
        weak var navigationManager: WorkoutSessionsNavigationManager?
        
        init(workoutRepository: any WorkoutSessionRepository,
             healthKitManager: HealthKitManager) {
            self.workoutRepository = workoutRepository
            self.healthKitManager = healthKitManager
            loadWorkouts()
        }
        
        func handleOnAppear() {
            loadWorkouts()
        }
        
        func loadWorkouts() {
            isLoading = true
            
            Task(priority: .background) { @MainActor in
                
                do {
                    let workouts = try await workoutRepository.getAll()
                    self.workouts = workouts
                } catch {
                    print("Error while loading workouts: \(error.localizedDescription)")
//                    self.workouts = Workout.mockedSet
                }
                
                isLoading = false
            }
        }
        
        func handleWorkoutTapped(for session: WorkoutSession) {
            navigationManager?.push(WorkoutRoute(workout: session))
        }
        
    }
}
