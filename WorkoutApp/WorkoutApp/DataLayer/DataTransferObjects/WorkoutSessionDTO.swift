//
//  WorkoutSessionDTO.swift
//  WorkoutApp
//
//  Created by Raul Pele on 04.03.2026.
//

import Foundation
import SwiftData

@Model
class WorkoutSessionDTO: DomainConvertible {

    // MARK: - Properties
    @Attribute(.unique) var id: UUID
    var title: String?
    var workoutTemplate: Workout
    var performedExercises: [PerformedExercise]
    var averageHeartRate: Int?
    var duration: TimeInterval?
    var startDate: Date?
    var endDate: Date?
    var totalCalories: Int?
    var activeCalories: Int?

    // MARK: - Initializers
    init(
        id: UUID,
        title: String?,
        workoutTemplate: Workout,
        performedExercises: [PerformedExercise],
        averageHeartRate: Int?,
        duration: TimeInterval?,
        startDate: Date?,
        endDate: Date?,
        totalCalories: Int?,
        activeCalories: Int?
    ) {
        self.id = id
        self.title = title
        self.workoutTemplate = workoutTemplate
        self.performedExercises = performedExercises
        self.averageHeartRate = averageHeartRate
        self.duration = duration
        self.startDate = startDate
        self.endDate = endDate
        self.totalCalories = totalCalories
        self.activeCalories = activeCalories
    }

    convenience init(from session: WorkoutSession) {
        self.init(
            id: session.id,
            title: session.title,
            workoutTemplate: session.workoutTemplate,
            performedExercises: session.performedExercises,
            averageHeartRate: session.averageHeartRate,
            duration: session.duration,
            startDate: session.startDate,
            endDate: session.endDate,
            totalCalories: session.totalCalories,
            activeCalories: session.activeCalories
        )
    }

    // MARK: - DomainConvertible
    func toDomain() -> WorkoutSession {
        WorkoutSession(
            id: id,
            title: title,
            workoutTemplate: workoutTemplate,
            performedExercises: performedExercises,
            averageHeartRate: averageHeartRate,
            duration: duration,
            startDate: startDate,
            endDate: endDate,
            totalCalories: totalCalories,
            activeCalories: activeCalories
        )
    }
}
