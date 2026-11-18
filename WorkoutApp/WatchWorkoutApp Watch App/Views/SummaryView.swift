//
//  SummaryView.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 11.05.2023.
//

import SwiftUI
import HealthKit

struct SummaryView: View {

    // MARK: - Properties
    @Environment(WorkoutManager.self) private var workoutManager

    private var isSaving: Bool {
        workoutManager.lifecycle == .saving
    }

    // MARK: - Body
    var body: some View {
        Group {
            switch workoutManager.lifecycle {
            case .finished:
                WorkoutSavedView(workoutManager: workoutManager)

            case .saveFailed(let message):
                SaveFailedView(message: message, onDone: workoutManager.dismissSummary)

            case .idle, .starting, .failedToStart, .active, .saving:
                ProgressView("Saving Workout")
                    .tint(.primaryColor)
            }
        }
        .toolbar(isSaving ? .hidden : .automatic, for: .navigationBar)
        .interactiveDismissDisabled(isSaving)
    }
}

// MARK: - WorkoutSavedView
private struct WorkoutSavedView: View {

    let workoutManager: WorkoutManager

    private var durationText: String {
        Duration.seconds(workoutManager.workout?.duration ?? 0)
            .formatted(.time(pattern: .hourMinuteSecond))
    }

    private var activeEnergyText: String {
        let kilocalories = workoutManager.workout?
            .statistics(for: HKQuantityType(.activeEnergyBurned))?
            .sumQuantity()?
            .doubleValue(for: .kilocalorie()) ?? 0

        return Measurement(value: kilocalories, unit: UnitEnergy.kilocalories)
            .formatted(
                .measurement(
                    width: .abbreviated,
                    usage: .workout,
                    numberFormatStyle: .number.precision(.fractionLength(0))
                )
            )
    }

    private var loggedSetCount: Int {
        workoutManager.exercisesToSave.reduce(0) { $0 + $1.sets.count }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                SummaryMetricView(title: "Total Time", value: durationText)
                    .foregroundStyle(.yellow)

                SummaryMetricView(title: "Active Energy", value: activeEnergyText)
                    .foregroundStyle(.pink)

                SummaryMetricView(
                    title: "Avg. Heart Rate",
                    value: workoutManager.averageHeartRate.formatted(.number.precision(.fractionLength(0))) + " bpm"
                )
                .foregroundStyle(.red)

                SummaryMetricView(title: "Sets Logged", value: loggedSetCount.formatted())
                    .foregroundStyle(Color.primaryColor)

                Text("Activity Rings")

                ActivityRingsView(healthStore: workoutManager.healthStore)
                    .frame(width: 50, height: 50)

                Button("Done", action: workoutManager.dismissSummary)
                    .tint(Color.primaryColor)
            }
            .scenePadding()
        }
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - SaveFailedView
private struct SaveFailedView: View {

    let message: String
    let onDone: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)

                Text("Not Saved")
                    .font(.headline)

                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Done", action: onDone)
                    .tint(Color.primaryColor)
            }
            .scenePadding()
        }
    }
}

// MARK: - SummaryMetricView
struct SummaryMetricView: View {

    var title: String
    var value: String

    var body: some View {
        Text(title)
            .foregroundStyle(.foreground)
        Text(value)
            .font(.system(.title2, design: .rounded).lowercaseSmallCaps())
        Divider()
    }
}
