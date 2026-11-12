//
//  HistoryView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - HistoryView
/// The History tab: sessions logged on the watch, newest first, with this week's totals on top.
struct HistoryView: View {

    // MARK: - Properties
    @Bindable var viewModel: HistoryViewModel
    let transitionNamespace: Namespace.ID

    // MARK: - Body
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                if !viewModel.sessions.isEmpty {
                    WeekSummaryCardView(summary: viewModel.weekSummary)
                }

                ForEach(viewModel.sections) { section in
                    SectionHeaderView(title: section.title)

                    ForEach(section.sessions) { session in
                        Button {
                            viewModel.handleSessionTapped(session)
                        } label: {
                            SessionCardView(session: session)
                        }
                        .buttonStyle(.plain)
                        .matchedTransitionSource(id: session.id, in: transitionNamespace)
                    }
                }
            }
            .padding()
        }
        .background(Color.background)
        .overlay {
            if viewModel.showsLoadError {
                EmptyStateView(
                    title: "Couldn't load your history",
                    message: viewModel.loadErrorMessage ?? "",
                    systemImage: "exclamationmark.triangle",
                    actionTitle: "Try Again",
                    action: { Task { await viewModel.load() } }
                )
            } else if viewModel.isEmpty {
                EmptyStateView(
                    title: "No workouts yet",
                    message: "Start a workout from your Apple Watch. Finished sessions show up here.",
                    systemImage: "applewatch"
                )
            } else if !viewModel.hasLoaded {
                ProgressView()
            }
        }
        .navigationTitle("History")
        .refreshable {
            await viewModel.load()
        }
        .task {
            await viewModel.load()
        }
    }
}

// MARK: - Previews
#Preview("With sessions") {
    @Previewable @Namespace var namespace
    NavigationStack {
        HistoryView(
            viewModel: HistoryViewModel(
                workoutRepository: MockedWorkoutSessionRepository(),
                navigationManager: WorkoutSessionsNavigationManager()
            ),
            transitionNamespace: namespace
        )
    }
}

#Preview("Empty") {
    @Previewable @Namespace var namespace
    NavigationStack {
        HistoryView(
            viewModel: HistoryViewModel(
                workoutRepository: MockedWorkoutSessionEmptyRepository(),
                navigationManager: WorkoutSessionsNavigationManager()
            ),
            transitionNamespace: namespace
        )
    }
}
