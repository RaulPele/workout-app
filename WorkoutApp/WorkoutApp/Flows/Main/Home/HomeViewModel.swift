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
        
        init(workoutRepository: any WorkoutRepository) {
            self.workoutRepository = workoutRepository
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
                }
                
                isLoading = false
            }
        }
        
    }
}
