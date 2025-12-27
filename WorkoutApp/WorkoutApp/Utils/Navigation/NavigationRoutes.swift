//
//  NavigationRoutes.swift
//  WorkoutApp
//
//  Created by Raul Pele on [Date]
//

import Foundation

/// Navigation route for Workout Details screen
struct WorkoutRoute: Hashable {
    let workout: Workout
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(workout.id)
    }
    
    static func == (lhs: WorkoutRoute, rhs: WorkoutRoute) -> Bool {
        lhs.workout.id == rhs.workout.id
    }
}

/// Navigation route for Workout Template Builder screen
struct WorkoutTemplateBuilderRoute: Hashable {}

