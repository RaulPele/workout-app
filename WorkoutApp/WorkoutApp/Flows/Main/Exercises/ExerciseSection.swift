//
//  ExerciseSection.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import Foundation

// MARK: - ExerciseSection
/// A group of library exercises shown under one muscle header.
struct ExerciseSection: Identifiable {
    let id: String
    let title: String
    let definitions: [ExerciseDefinition]

    /// Groups definitions by their first primary muscle, in `MuscleGroup` order,
    /// with exercises that have no muscle set collected under "Other" at the end.
    static func grouped(_ definitions: [ExerciseDefinition]) -> [ExerciseSection] {
        let byMuscle = Dictionary(grouping: definitions) { $0.primaryMuscles.first }

        var sections = MuscleGroup.allCases.compactMap { muscle -> ExerciseSection? in
            guard let items = byMuscle[muscle], !items.isEmpty else { return nil }
            return ExerciseSection(id: muscle.rawValue, title: muscle.displayName, definitions: items)
        }

        if let other = byMuscle[nil], !other.isEmpty {
            sections.append(ExerciseSection(id: "other", title: "Other", definitions: other))
        }
        return sections
    }
}
