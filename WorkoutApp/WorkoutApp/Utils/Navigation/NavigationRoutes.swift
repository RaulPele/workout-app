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

/// Navigation route for the read-only Workout Template Detail screen
struct WorkoutTemplateDetailRoute: Hashable {
    let workoutId: UUID
}
