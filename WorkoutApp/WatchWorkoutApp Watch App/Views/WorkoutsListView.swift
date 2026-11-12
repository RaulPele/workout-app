//
//  WorkoutsListView.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 11.05.2023.
//

import SwiftUI
import HealthKit
import WatchKit

struct WorkoutsListView: View {

    // MARK: - Properties
    @Environment(WorkoutManager.self) private var workoutManager

    // MARK: - Body
    var body: some View {
        Group {
            if workoutManager.isLoading && workoutManager.workoutTemplates.isEmpty {
                ZStack {
                    Color.background.ignoresSafeArea()
                    ActivityIndicator(color: .primaryColor) //TODO: check if this needs to be fixed or not
                }
            } else if workoutManager.loadError != nil && workoutManager.workoutTemplates.isEmpty {
                ErrorStateView { //TODO: validate
                    Task { await workoutManager.loadWorkoutTemplates() }
                }
            } else if workoutManager.workoutTemplates.isEmpty {
                EmptyStateView()
            } else {
                List(workoutManager.workoutTemplates) { template in
                    NavigationLink(value: WatchWorkoutSessionRoute(workoutTemplate: template)) {
                        WorkoutTemplateCard(workout: template)
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                }
                .listStyle(.carousel)
            }
        }
        .navigationTitle("Workouts")
        .task {
            await workoutManager.loadWorkoutTemplates()
        }
    }
}

// MARK: - WorkoutTemplateCard
private struct WorkoutTemplateCard: View {

    let workout: Workout

    var body: some View {
        Text(workout.name)
            .font(.title3)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .foregroundStyle(Color.onSurface)
            .frame(maxWidth: .infinity, minHeight: 120)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surface)
            )
    }
}

// MARK: - EmptyStateView
private struct EmptyStateView: View {

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("No Workouts")
                .font(.headline)

            Text("Create workout templates on your iPhone to get started.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .scenePadding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - ErrorStateView
private struct ErrorStateView: View {

    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "iphone.slash")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("Unable to Load")
                .font(.headline)

            Text("Check that your iPhone is nearby.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry", action: onRetry)
                .buttonStyle(.bordered)
                .tint(Color.primaryColor)
        }
        .scenePadding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - HKWorkoutActivityType + Identifiable
extension HKWorkoutActivityType: Identifiable { //TODO: fix the warning here
    public var id: UInt {
        rawValue
    }

    var name: String {
        switch self {
        case .traditionalStrengthTraining:
            return "Traditional Strength Training"

        default:
            return ""
        }
    }
}

#if DEBUG
#Preview("With Templates") {
    NavigationStack {
        WorkoutsListView()
            .environment(WorkoutManager(phoneCommunicator: MockedPhoneCommunicator()))
    }
}
#endif
