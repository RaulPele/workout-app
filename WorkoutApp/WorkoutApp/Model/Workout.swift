//
//  Workout.swift
//  WorkoutApp
//
//  Created by Raul Pele on 02.05.2023.
//

import Foundation

struct Workout: Identifiable, Hashable {
    
    let id: UUID
    let title: String //TODO: change type from string to workout type
    let averageHeartRate: Int //TODO: show all heart rate intervals
    let duration: TimeInterval //TODO: workout start time workout end time
    let totalCalories: Int
    let activeCalories: Int
    let date: Date
}
