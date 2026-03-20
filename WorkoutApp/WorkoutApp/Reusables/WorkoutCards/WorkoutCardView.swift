//
//  WorkoutCardView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 02.05.2023.
//

import SwiftUI

// MARK: - TimeInterval Formatting
extension TimeInterval {

    func formatted() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: self) ?? "cannot format date"
    }
}

// MARK: - WorkoutCardView
struct WorkoutCardView: View {

    let workout: WorkoutSession

    private let cardCornerRadius: CGFloat = 14

    var body: some View {
        HStack(spacing: 0) {
            AccentBar()

            VStack(alignment: .leading, spacing: 8) {
                CardHeader(
                    title: workout.title ?? "No Title",
                    templateName: workout.workoutTemplate.name,
                    date: workout.endDate ?? .now
                )

                MetricsRow(
                    duration: workout.duration,
                    calories: workout.activeCalories,
                    heartRate: workout.averageHeartRate
                )
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
    let templateName: String
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.onSurface)
                    .lineLimit(1)

                Spacer()

                Text(date, format: .dateTime.month(.abbreviated).day())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(templateName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

// MARK: - Metrics Row
private struct MetricsRow: View {
    let duration: TimeInterval?
    let calories: Int?
    let heartRate: Int?

    var body: some View {
        HStack(spacing: 16) {
            MetricItem(
                icon: "clock.fill",
                value: duration?.formatted() ?? "0m 0s",
                color: .green
            )

            MetricItem(
                icon: "flame.fill",
                value: "\(calories ?? 0) kcal",
                color: .primaryColor
            )

            if let heartRate {
                MetricItem(
                    icon: "heart.fill",
                    value: "\(heartRate) bpm",
                    color: .red
                )
            }
        }
    }
}

// MARK: - Metric Item
private struct MetricItem: View {
    let icon: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)

            Text(value)
                .font(.caption)
                .foregroundStyle(Color.onSurface)
        }
    }
}

#if DEBUG
struct WorkoutCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            VStack(spacing: 12) {
                WorkoutCardView(workout: .mocked1)
                WorkoutCardView(workout: .mocked2)
            }
            .padding()
        }
    }
}
#endif
