//
//  NavigationRoutes.swift
//  WorkoutApp
//
//  Created by Raul Pele on [Date]
//

import Foundation

/// Navigation route for Workout Details screen
struct WorkoutRoute: Hashable {
    let workout: WorkoutSession
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(workout.id)
    }
    
    static func == (lhs: WorkoutRoute, rhs: WorkoutRoute) -> Bool {
        lhs.workout.id == rhs.workout.id
    }
}

/// Navigation route for Workout Template Builder screen
struct WorkoutTemplateBuilderRoute: Hashable {
    let workout: Workout?

    init(workout: Workout? = nil) {
        self.workout = workout
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(workout?.id)
    }

    static func == (lhs: WorkoutTemplateBuilderRoute, rhs: WorkoutTemplateBuilderRoute) -> Bool {
        lhs.workout?.id == rhs.workout?.id
    }
}

