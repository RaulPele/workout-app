//
//  WorkoutTemplateCardView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 30.05.2023.
//

import SwiftUI

struct WorkoutTemplateCardView: View {

    let workout: Workout

    private let cardCornerRadius: CGFloat = 14
    private let maxVisibleExercises = 4

    var body: some View {
        HStack(spacing: 0) {
            AccentBar()

            VStack(alignment: .leading, spacing: 6) {
                CardHeader(
                    title: workout.name,
                    exerciseCount: workout.exercises.count
                )

                if !workout.exercises.isEmpty {
                    ExerciseSummary(
                        exercises: workout.exercises,
                        maxVisible: maxVisibleExercises
                    )
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.surface)
        .clipShape(.rect(cornerRadius: cardCornerRadius))
    }
}

// MARK: - Accent Bar

private struct AccentBar: View {
    var body: some View {
        Color.primaryColor
            .frame(width: 4)
    }
}

// MARK: - Card Header

private struct CardHeader: View {
    let title: String
    let exerciseCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.onSurface)
                .lineLimit(2)

            Text(exerciseCountText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var exerciseCountText: String {
        "\(exerciseCount) \(exerciseCount == 1 ? "exercise" : "exercises")"
    }
}

// MARK: - Exercise Summary

private struct ExerciseSummary: View {
    let exercises: [Exercise]
    let maxVisible: Int

    var body: some View {
        Text(summaryText)
            .font(.footnote)
            .foregroundStyle(.tertiary)
            .lineLimit(1)
    }

    private var summaryText: String {
        let visible = exercises.prefix(maxVisible).map(\.name)
        let remaining = exercises.count - maxVisible

        if remaining > 0 {
            return visible.joined(separator: ", ") + " +\(remaining)"
        }
        return visible.joined(separator: ", ")
    }
}

#Preview {
    ZStack {
        Color.background
            .ignoresSafeArea()

        VStack(spacing: 12) {
            WorkoutTemplateCardView(workout: .mockedWorkoutTemplate)
            WorkoutTemplateCardView(workout: .mockedWorkoutTemplate)
        }
        .padding()
    }
}
