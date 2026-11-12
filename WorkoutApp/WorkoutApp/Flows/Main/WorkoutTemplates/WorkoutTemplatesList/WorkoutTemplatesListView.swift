//
//  WorkoutTemplatesListView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 29.05.2023.
//

import SwiftUI

struct WorkoutTemplatesList {

    /// The Workouts tab: your workout templates as cards.
    struct ContentView: View {

        // MARK: - Properties
        @Bindable var viewModel: ViewModel
        let transitionNamespace: Namespace.ID

        // MARK: - Body
        var body: some View {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.workouts) { workout in
                        Button {
                            viewModel.handleTemplateTapped(workout)
                        } label: {
                            WorkoutTemplateCardView(workout: workout)
                        }
                        .buttonStyle(.plain)
                        .matchedTransitionSource(id: workout.id, in: transitionNamespace)
                        .contextMenu {
                            Button("Edit", systemImage: "pencil") { viewModel.handleEditTapped(workout) }
                            Button("Duplicate", systemImage: "plus.square.on.square") { viewModel.handleDuplicateTapped(workout) }
                            Button("Delete", systemImage: "trash", role: .destructive) { viewModel.handleDeleteTapped(workout) }
                        }
                        .accessibilityAction(named: "Edit") { viewModel.handleEditTapped(workout) }
                        .accessibilityAction(named: "Duplicate") { viewModel.handleDuplicateTapped(workout) }
                        .accessibilityAction(named: "Delete") { viewModel.handleDeleteTapped(workout) }
                    }
                }
                .padding()
            }
            .background(Color.background)
            .overlay {
                if viewModel.isEmpty {
                    EmptyStateView(
                        title: "Build your first workout",
                        message: "Pick exercises, set your sets and reps, and it syncs to your Apple Watch.",
                        systemImage: "dumbbell",
                        actionTitle: "New Workout",
                        action: viewModel.handleAddButtonTapped
                    )
                } else if !viewModel.hasLoaded {
                    ProgressView()
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("New Workout", systemImage: "plus", action: viewModel.handleAddButtonTapped)
                }
            }
            .refreshable {
                await viewModel.load()
            }
            .sheet(item: $viewModel.activeSheet) { sheet in
                WorkoutTemplateEditorSheet(workout: sheet.workout)
            }
            .confirmationDialog(
                "Delete \(viewModel.pendingDeletion?.name ?? "workout")?",
                isPresented: Binding(presenting: $viewModel.pendingDeletion),
                titleVisibility: .visible
            ) {
                Button("Delete Workout", role: .destructive, action: viewModel.confirmDeletion)
            } message: {
                Text("It's also removed from your Apple Watch. Past sessions stay in History.")
            }
            .alert("Something Went Wrong", isPresented: Binding(presenting: $viewModel.errorMessage)) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .task {
                await viewModel.load()
            }
        }
    }
}

// MARK: - Previews
#Preview {
    @Previewable @Namespace var namespace

    NavigationStack {
        WorkoutTemplatesList.ContentView(
            viewModel: .init(
                workoutTemplateRepository: MockedWorkoutRepository(),
                navigationManager: WorkoutTemplatesNavigationManager()
            ),
            transitionNamespace: namespace
        )
    }
}
