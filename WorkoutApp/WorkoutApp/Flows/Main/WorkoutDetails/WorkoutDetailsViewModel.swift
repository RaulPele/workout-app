//
//  WorkoutDetailsViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 04.05.2023.
//

import Foundation
import SwiftUI

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
            
//        case .duration:
//            return value
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
        @Published var workout: WorkoutSession
        var workoutDetailsData = [RowData]()
//        var exercisesData = [PerformedExercise]()
        
        init(workout: WorkoutSession) {
            self.workout = workout
            computeWorkoutDetailsData()
//            computeExercisesData()
        }
        
        //MARK: - Compute data for display
        private func computeWorkoutDetailsData() {
            let avgHeartRate = WorkoutCharacteristic(key: .avgHeartRate, value: "\(workout.averageHeartRate ?? 0)")
            let totalCalories = WorkoutCharacteristic(key: .totalCalories, value: "\(workout.totalCalories ?? 0)")
            let activecalories = WorkoutCharacteristic(key: .activeCalories, value: "\(workout.activeCalories ?? 0)")
            let duration = WorkoutCharacteristic(key: .duration, value: workout.duration?.formatted() ?? "0:00:00")
            
            self.workoutDetailsData = [
                .init(first: duration, second: avgHeartRate),
                .init(first: activecalories, second: totalCalories)
            ]
        }
        
       
    }
}
