//
//  Workout+Summary.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import Foundation

extension Workout {

    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.numberOfSets }
    }

    var totalReps: Int {
        exercises.reduce(0) { $0 + $1.numberOfSets * $1.setData.reps }
    }

    /// "5 exercises · 17 sets"
    var countsSummary: String {
        let exerciseCount = exercises.count
        let exercisesText = "\(exerciseCount) \(exerciseCount == 1 ? "exercise" : "exercises")"
        let setsText = "\(totalSets) \(totalSets == 1 ? "set" : "sets")"
        return "\(exercisesText) · \(setsText)"
    }

    /// The first few exercise names, e.g. "Bench Press, Dips, Row +2".
    func exercisePreview(maxVisible: Int = 3) -> String {
        let names = exercises.prefix(maxVisible).map(\.name).joined(separator: ", ")
        let remaining = exercises.count - maxVisible
        return remaining > 0 ? "\(names) +\(remaining)" : names
    }

    /// The muscles this workout trains most, weighted by number of sets.
    func topMuscles(limit: Int = 3) -> [MuscleGroup] {
        var setsPerMuscle: [MuscleGroup: Int] = [:]
        var firstSeen: [MuscleGroup] = []

        for exercise in exercises {
            for muscle in exercise.definition.primaryMuscles {
                if setsPerMuscle[muscle] == nil {
                    firstSeen.append(muscle)
                }
                setsPerMuscle[muscle, default: 0] += exercise.numberOfSets
            }
        }

        return firstSeen
            .enumerated()
            .sorted { lhs, rhs in
                let lhsSets = setsPerMuscle[lhs.element] ?? 0
                let rhsSets = setsPerMuscle[rhs.element] ?? 0
                return lhsSets == rhsSets ? lhs.offset < rhs.offset : lhsSets > rhsSets
            }
            .prefix(limit)
            .map(\.element)
    }
}
