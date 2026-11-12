//
//  WorkoutSession+Summary.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import Foundation

extension WorkoutSession {

    /// Number of sets actually logged.
    var completedSetCount: Int {
        performedExercises.reduce(0) { $0 + $1.sets.count }
    }

    /// Number of sets the template asked for.
    var plannedSetCount: Int {
        workoutTemplate.totalSets
    }

    /// Total weight lifted (reps × weight) in kilograms.
    var volume: Double {
        performedExercises
            .flatMap(\.sets)
            .reduce(0) { $0 + Double($1.reps) * $1.weight }
    }

    /// Stored duration, or the time between start and end when it's missing.
    var resolvedDuration: TimeInterval? {
        if let duration {
            return duration
        }
        guard let startDate, let endDate else { return nil }
        return endDate.timeIntervalSince(startDate)
    }

    /// The date used to sort and group sessions.
    var sortDate: Date {
        endDate ?? startDate ?? .distantPast
    }
}
