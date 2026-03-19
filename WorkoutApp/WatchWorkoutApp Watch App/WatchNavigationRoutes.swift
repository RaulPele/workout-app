//
//  WatchNavigationRoutes.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 19.03.2026.
//

import Foundation

struct WatchWorkoutSessionRoute: Hashable {
    let workoutTemplate: Workout

    func hash(into hasher: inout Hasher) {
        hasher.combine(workoutTemplate.id)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.workoutTemplate.id == rhs.workoutTemplate.id
    }
}
