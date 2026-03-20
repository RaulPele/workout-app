//
//  WorkoutDetailsView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 04.05.2023.
//

import SwiftUI

struct WorkoutDetails {

    struct ContentView: View {

        // MARK: - Properties
        var viewModel: ViewModel

        // MARK: - Body
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    SessionHeaderView(
                        templateName: viewModel.templateName,
                        dateFormatted: viewModel.sessionDateFormatted,
                        timeRange: viewModel.sessionTimeRange
                    )
                    MetricsGridView(
                        duration: viewModel.durationFormatted,
                        averageHeartRate: viewModel.averageHeartRateFormatted,
                        activeCalories: viewModel.activeCaloriesFormatted,
                        totalCalories: viewModel.totalCaloriesFormatted
                    )
                    ExercisesSectionView(exercises: viewModel.session.performedExercises)
                }
                .padding(.horizontal)
            }
            .background(Color.background)
            .navigationTitle(viewModel.sessionTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - SessionHeaderView
private struct SessionHeaderView: View {

    let templateName: String
    let dateFormatted: String?
    let timeRange: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(templateName)
                .font(.heading3)
                .foregroundStyle(Color.primaryColor)

            if let dateFormatted {
                Label(dateFormatted, systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundStyle(Color.onSurface)
            }

            if let timeRange {
                Label(timeRange, systemImage: "clock")
                    .font(.subheadline)
                    .foregroundStyle(Color.onSurface)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.surface)
        }
    }
}

// MARK: - MetricsGridView
private struct MetricsGridView: View {

    let duration: String
    let averageHeartRate: String
    let activeCalories: String
    let totalCalories: String

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            MetricCardView(
                icon: "timer",
                value: duration,
                label: "Duration",
                iconColor: .green
            )

            MetricCardView(
                icon: "heart.fill",
                value: averageHeartRate,
                label: "Avg Heart Rate",
                iconColor: .red
            )

            MetricCardView(
                icon: "flame.fill",
                value: activeCalories,
                label: "Active Cal.",
                iconColor: .primaryColor
            )

            MetricCardView(
                icon: "bolt.fill",
                value: totalCalories,
                label: "Total Cal.",
                iconColor: .primaryColor
            )
        }
    }
}

// MARK: - MetricCardView
private struct MetricCardView: View {

    let icon: String
    let value: String
    let label: String
    let iconColor: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)

            Text(value)
                .font(.heading3)
                .foregroundStyle(Color.onSurface)

            Text(label)
                .font(.caption)
                .foregroundStyle(Color.onSurface.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.surface2)
        }
    }
}

// MARK: - ExercisesSectionView
private struct ExercisesSectionView: View {

    let exercises: [PerformedExercise]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Exercises")
                .foregroundStyle(Color.onBackground)
                .font(.heading2)

            ForEach(exercises) { exercise in
                PerformedExerciseCardView(performedExercise: exercise)
            }
        }
    }
}

// MARK: - PerformedExerciseCardView
private struct PerformedExerciseCardView: View {

    let performedExercise: PerformedExercise
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            headerButton

            if isExpanded {
                Divider()

                setsTable
                    .padding(.top, 4)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.surface2)
        }
    }

    // MARK: - Private Views
    private var headerButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(performedExercise.exercise.name)
                        .font(.headline)
                        .foregroundStyle(Color.onSurface)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(Color.onSurface.opacity(0.5))
                }

                HStack(spacing: 6) {
                    metricCapsule(
                        systemImage: "checkmark",
                        text: "\(performedExercise.sets.count)/\(performedExercise.exercise.numberOfSets) Sets"
                    )

                    metricCapsule(
                        systemImage: "number",
                        text: "\(performedExercise.exercise.setData.reps) Reps target"
                    )
                }
            }
        }
    }

    private var setsTable: some View {
        VStack(spacing: 0) {
            HStack {
                Text("SET")
                    .frame(width: 36, alignment: .leading)
                Text("REPS")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("WEIGHT")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("REST")
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(.caption2)
            .foregroundStyle(Color.onSurface.opacity(0.5))
            .padding(.bottom, 8)

            ForEach(Array(performedExercise.sets.enumerated()), id: \.element.id) { index, performedSet in
                SetRowView(
                    index: index,
                    performedSet: performedSet,
                    isLastSet: index == performedExercise.sets.count - 1
                )
            }
        }
    }

    private func metricCapsule(systemImage: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.caption2)
                .foregroundStyle(Color.primaryColor)

            Text(text)
                .font(.caption)
                .foregroundStyle(Color.onBackground)
        }
        .lineLimit(1)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background {
            Capsule(style: .continuous)
                .fill(Color.primaryColor.opacity(0.1))
        }
    }
}

// MARK: - SetRowView
private struct SetRowView: View {

    let index: Int
    let performedSet: PerformedSet
    let isLastSet: Bool

    var body: some View {
        HStack {
            Text("\(index + 1)")
                .frame(width: 36, alignment: .leading)

            Text("\(performedSet.reps)")
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(performedSet.weight.formatted(.number)) kg")
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(isLastSet ? "--" : performedSet.restTime.formatted())
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.subheadline)
        .foregroundStyle(Color.onSurface)
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        WorkoutDetails.ContentView(viewModel: .init(session: .mocked1))
    }
}
