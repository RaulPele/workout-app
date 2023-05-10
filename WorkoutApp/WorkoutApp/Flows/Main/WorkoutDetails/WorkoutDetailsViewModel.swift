//
//  WorkoutDetailsViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 04.05.2023.
//

import Foundation


struct WorkoutCharacteristic: Identifiable {
    
    var id: String { self.key.title}
    
    let key: Key
    let value: String
    
    enum Key {
        
        case avgHeartRate
        case activeCalories
        case totalCalories
        case duration
        
        var title: String {
            
            switch self {
            case .avgHeartRate:
                return "AVG Heart rate"
                
            case .activeCalories:
                return "Active calories"
                
            case .totalCalories:
                return "Total calories"
                
            case .duration:
                return "Workout time"
            }
        }
    }
    
    var displayValue: String {
        switch self.key {
        case .avgHeartRate:
            return "\(value) BPM"
            
        case .activeCalories, .totalCalories:
            return "\(value) KCAL"
            
        default:
            return value
        }
    }
}

extension WorkoutDetails {
    
    struct RowData: Identifiable {
        let id = UUID()
        
        let first: WorkoutCharacteristic
        let second: WorkoutCharacteristic
    }
    
    class ViewModel: ObservableObject {
        
        @Published var isLoading: Bool = false
        @Published var workout: Workout
        var workoutDetailsData = [RowData]()
        
        var onBack: (() -> Void)?
        
        init(workout: Workout) {
            self.workout = workout
            computeWorkoutDetailsData()
        }
        
        private func computeWorkoutDetailsData() {
            let avgHeartRate = WorkoutCharacteristic(key: .avgHeartRate, value: "\(workout.averageHeartRate)")
            let totalCalories = WorkoutCharacteristic(key: .totalCalories, value: "\(workout.totalCalories)")
            let activecalories = WorkoutCharacteristic(key: .activeCalories, value: "\(workout.activeCalories)")
            let duration = WorkoutCharacteristic(key: .duration, value: workout.duration.formatted())
            
            self.workoutDetailsData = [
                .init(first: duration, second: avgHeartRate),
                .init(first: activecalories, second: totalCalories)
            ]
        }
    }
}
