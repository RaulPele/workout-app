//
//  Workout.swift
//  WorkoutApp
//
//  Created by Raul Pele on 02.05.2023.
//

import Foundation

struct Workout: Identifiable, Codable, Hashable {
    
    var id: UUID
    var title: String?
    let workoutTemplate: WorkoutTemplate
    var performedExercises: [PerformedExercise]
    var averageHeartRate: Int? //TODO: show all heart rate intervals
    var duration: TimeInterval? //TODO: workout start time workout end time
    var startDate: Date? //TODO: remove duration field or convert to computed property
    var endDate: Date?
    var totalCalories: Int?
    var activeCalories: Int?
}
