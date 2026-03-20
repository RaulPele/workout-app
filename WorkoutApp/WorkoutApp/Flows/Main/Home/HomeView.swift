//
// HomeView.swift
// WorkoutApp
//
// Created by Raul Pele on 02.05.2023.
//
//

import Foundation
import SwiftUI

struct Home {

    struct ContentView: View {

        var viewModel: ViewModel

        var body: some View {
            ScrollView {
                if viewModel.workouts.isEmpty && !viewModel.isLoading {
                    EmptyStateView()
                } else if !viewModel.workouts.isEmpty {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.groupedWorkouts) { group in
                            WorkoutSectionView(
                                group: group,
                                onSessionTapped: { session in
                                    viewModel.handleWorkoutTapped(for: session)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Sessions")
            .navigationSubtitle(sessionCountSubtitle)
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color.background)
            .refreshable {
                await viewModel.refreshWorkouts()
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlayView()
                }
            }
        }

        private var sessionCountSubtitle: String {
            let count = viewModel.workouts.count
            return "\(count) session\(count == 1 ? "" : "s")"
        }
    }
}

// MARK: - Loading Overlay View
private struct LoadingOverlayView: View {
    var body: some View {
        ZStack {
            Color.background.opacity(0.8)
            ProgressView()
                .scaleEffect(1.2)
        }
    }
}

// MARK: - Workout Section View
private struct WorkoutSectionView: View {
    let group: WorkoutSessionGroup
    let onSessionTapped: (WorkoutSession) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: group.title)

            ForEach(group.sessions) { session in
                SessionCardButton(
                    session: session,
                    onTap: { onSessionTapped(session) }
                )
            }
        }
    }
}

// MARK: - Section Header View
private struct SectionHeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.heading3)
            .foregroundStyle(Color.onBackground)
    }
}

// MARK: - Session Card Button
private struct SessionCardButton: View {
    let session: WorkoutSession
    let onTap: () -> Void
    @State private var tapCount = 0

    var body: some View {
        Button(action: {
            tapCount += 1
            onTap()
        }) {
            WorkoutCardView(workout: session)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: tapCount)
    }
}

// MARK: - Empty State View
private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.largeTitle)
                .foregroundStyle(.secondary.opacity(0.6))

            VStack(spacing: 4) {
                Text("No Workout Sessions")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.onBackground)

                Text("Complete a workout on your Apple Watch to see it here")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
}

//MARK: - Previews
#Preview("With sessions") {
    NavigationStack {
        Home.ContentView(
            viewModel: .init(
                workoutRepository: MockedWorkoutSessionRepository(),
                healthKitManager: MockedHealthKitManager(),
                navigationManager: WorkoutSessionsNavigationManager()
            )
        )
    }
}

#Preview("Empty") {
    NavigationStack {
        Home.ContentView(
            viewModel: .init(
                workoutRepository: MockedWorkoutSessionEmptyRepository(),
                healthKitManager: MockedHealthKitManager(),
                navigationManager: WorkoutSessionsNavigationManager()
            )
        )
    }
}
