//
//  MetricsPageView.swift
//  WatchWorkoutApp Watch App
//

import SwiftUI

struct MetricsPageView: View {

    // MARK: - Properties
    @Environment(WorkoutManager.self) private var workoutManager

    // MARK: - Body
    var body: some View {
        TimelineView(
            MetricsTimelineSchedule(
                from: workoutManager.workoutStartDate ?? Date(),
                isPaused: workoutManager.isSessionPaused
            )
        ) { context in
            VStack(alignment: .leading, spacing: 16) {
                ElapsedTimeView(
                    elapsedTime: workoutManager.elapsedTime(at: context.date),
                    showSubseconds: context.cadence == .live
                )
                .foregroundStyle(.yellow)

                metricRow(
                    icon: "flame.fill",
                    color: .orange
                ) {
                    Text(
                        Measurement(
                            value: workoutManager.activeEnergyBurned,
                            unit: UnitEnergy.kilocalories
                        )
                        .formatted(
                            .measurement(
                                width: .abbreviated,
                                usage: .workout,
                                numberFormatStyle: .number.precision(.fractionLength(0))
                            )
                        )
                    )
                }

                metricRow(
                    icon: "heart.fill",
                    color: .red
                ) {
                    Text(workoutManager.heartRate.formatted(.number.precision(.fractionLength(0))) + " bpm")
                }
            }
            .font(.system(.title3, design: .rounded).monospacedDigit().lowercaseSmallCaps())
            .frame(maxWidth: .infinity, alignment: .leading)
            .scenePadding()
        }
    }

    // MARK: - Private Methods
    @ViewBuilder
    private func metricRow<Content: View>(icon: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.body)
                .frame(width: 20)

            content()
        }
    }
}

// MARK: - MetricsTimelineSchedule
private struct MetricsTimelineSchedule: TimelineSchedule {

    var startDate: Date
    var isPaused: Bool

    init(from startDate: Date, isPaused: Bool) {
        self.startDate = startDate
        self.isPaused = isPaused
    }

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> AnyIterator<Date> {
        let interval: TimeInterval = mode == .lowFrequency ? 1.0 : 1.0 / 30.0
        var baseSchedule = PeriodicTimelineSchedule(from: self.startDate, by: interval)
            .entries(from: startDate, mode: mode)

        return AnyIterator<Date> {
            guard !isPaused else { return nil }
            return baseSchedule.next()
        }
    }
}
