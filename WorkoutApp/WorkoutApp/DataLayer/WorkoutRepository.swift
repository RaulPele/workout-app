//
//  WorkoutRepository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.05.2023.
//

import Foundation
import HealthKit

protocol WorkoutRepository: Repository where T == Workout {
    
}

//extension HKWorkout {
//    func toModelWorkout() -> Workout {
//        return Workout(
//            id: hkW, title: <#T##String#>, workoutTemplate: <#T##WorkoutTemplate#>, performedExercises: <#T##[PerformedExercise]#>, averageHeartRate: <#T##Int#>, duration: <#T##TimeInterval#>, startDate: <#T##Date#>, endDate: <#T##Date#>, totalCalories: <#T##Int#>, activeCalories: <#T##Int#>)
//    }
//}

class WorkoutAPIRepository: WorkoutRepository {
    
    private let workoutService: WorkoutService
    private let healthKitManager: HealthKitManager
    private let workoutParser: WorkoutParser
    
    init(workoutService: WorkoutService,
         healthKitManager: HealthKitManager) {
        self.workoutService = workoutService
        self.healthKitManager = healthKitManager
        self.workoutParser = WorkoutParser(healthKitManager: healthKitManager)
    }
    
    func getAll() async throws -> [Workout] {
        let hkWorkouts = try await healthKitManager.loadWorkouts() //TODO: use higher order functions
//        let workouts = hkWorkouts.map {
//            let averageHeartRate = try await healthKitManager.getAverageHeartRate(for: $0)
//            Workout(
//                id: $0.uuid,
//                title: "Strength workout",
//                workoutTemplate: .mockedWorkoutTemplate,
//                performedExercises: [.mockedBBBenchPress],
//                averageHeartRate: , duration: <#T##TimeInterval#>, startDate: <#T##Date#>, endDate: <#T##Date#>, totalCalories: <#T##Int#>, activeCalories: <#T##Int#>)
//        }
        return try await workoutParser.toModelWorkouts(hkWorkouts)
    }
}


class MockedWorkoutRepository: WorkoutRepository {
    
    private let workoutService: WorkoutService = MockedWorkoutService()
    
    func getAll() async throws -> [Workout] {
        return try await workoutService.getAll()
    }
}
