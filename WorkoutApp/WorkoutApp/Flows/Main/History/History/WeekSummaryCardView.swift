//
//  WeekSummaryCardView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - WeekSummaryCardView
/// This week's totals: workouts, time and sets.
struct WeekSummaryCardView: View {

    // MARK: - Properties
    let summary: WeekSummary

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var valuesLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(spacing: 10))
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("This week")
                .font(.subheadline)
                .bold()
                .foregroundStyle(Color.primaryColor)

            if summary.workoutCount == 0 {
                Text("No workouts yet this week.")
                    .font(.headline)
                    .foregroundStyle(Color.onSurface)
            } else {
                valuesLayout {
                    WeekSummaryValueView(value: "\(summary.workoutCount)", label: summary.workoutCount == 1 ? "workout" : "workouts")
                    WeekSummaryValueView(value: summary.totalDuration.durationFormatted, label: "time")
                    WeekSummaryValueView(value: "\(summary.totalSets)", label: "sets")
                }
            }
        }
        .cardStyle(background: Color.primaryColor.opacity(0.1))
        .accessibilityElement(children: .combine)
    }
}
