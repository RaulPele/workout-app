//
//  Exercise+Formatting.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import Foundation

extension Exercise {

    /// Sets and reps target, e.g. "3 × 10".
    var targetSummary: String {
        "\(numberOfSets) × \(setData.reps)"
    }

    /// Rest between sets, e.g. "1:30 rest".
    var restSummary: String {
        "\(restBetweenSets.restFormatted) rest"
    }
}

extension ExerciseDefinition {

    /// Muscles and equipment, e.g. "Chest, Triceps · Barbell". `nil` when neither is set.
    var detailSummary: String? {
        let muscles = primaryMuscles.map(\.displayName).joined(separator: ", ")
        let parts = [muscles.isEmpty ? nil : muscles, equipment?.displayName].compactMap(\.self)
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}
