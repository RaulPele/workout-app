//
//  WorkoutTemplateDetailHeaderView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - WorkoutTemplateDetailHeaderView
/// The muscles a workout trains and its headline numbers.
struct WorkoutTemplateDetailHeaderView: View {

    // MARK: - Properties
    let workout: Workout

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            let muscles = workout.topMuscles(limit: 5)
            if !muscles.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(muscles, id: \.self) { muscle in
                        PillView(text: muscle.displayName, style: .accent, isMonospaced: false)
                    }
                }
            }

            HStack(spacing: 10) {
                StatTileView(value: "\(workout.exercises.count)", label: workout.exercises.count == 1 ? "exercise" : "exercises")
                StatTileView(value: "\(workout.totalSets)", label: workout.totalSets == 1 ? "set" : "sets")
                StatTileView(value: "\(workout.totalReps)", label: "reps")
            }
        }
    }
}
