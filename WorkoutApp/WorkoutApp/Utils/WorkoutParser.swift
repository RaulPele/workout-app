//
//  WorkoutParser.swift
//  WorkoutApp
//
//  Created by Raul Pele on 09.05.2023.
//

import Foundation
import HealthKit

struct WorkoutParser {
    
    let healthKitManager: HealthKitManager
    
    func toModelWorkout(_ workout: HKWorkout) async throws -> Workout {
        let title = WorkoutTemplate.mockedWorkoutTemplate.name//TODO: change
        let averageHeartRate = try await healthKitManager.getAverageHeartRate(for: workout)
        let duration = workout.duration
        
        let totalCalories = Int(workout.totalCalories ?? 0)
        let activeCalories = Int(workout.activeEnergyBurned ?? 0)
        
        let modelWorkout = Workout(id: workout.uuid,
                                   title: title,
                                   workoutTemplate: .mockedWorkoutTemplate,
                                   performedExercises: [.mockedBBBenchPress, .mockedBBSquats],
                                   averageHeartRate: Int(averageHeartRate),
                                   duration: duration,
                                   startDate: workout.startDate,
                                   endDate: workout.endDate,
                                   totalCalories: totalCalories,
                                   activeCalories: activeCalories)
        
        return modelWorkout
    }
    
    func toModelWorkouts(_ workouts: [HKWorkout]) async throws -> [Workout] {
        var modelWorkouts = [Workout]()
        
        for workout in workouts {
            let modelWorkout = try await toModelWorkout(workout)
            modelWorkouts.append(modelWorkout)
        }
        
        return modelWorkouts
    }
}
