//
//  WorkoutTemplateDetailView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - WorkoutTemplateDetailView
/// A read-only overview of a workout template, with Edit, Duplicate and Delete.
struct WorkoutTemplateDetailView: View {

    // MARK: - Properties
    @Bindable var viewModel: WorkoutTemplateDetailViewModel

    // MARK: - Body
    var body: some View {
        Group {
            if let workout = viewModel.workout {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        WorkoutTemplateDetailHeaderView(workout: workout)

                        SectionHeaderView(title: "Exercises")

                        ForEach(workout.exercises.enumerated(), id: \.element.id) { index, exercise in
                            TemplateExerciseCardView(position: index + 1, exercise: exercise)
                        }

                        WatchHintCardView()
                            .padding(.top, 8)
                    }
                    .padding()
                }
                .navigationTitle(workout.name)
            } else if viewModel.hasLoaded {
                EmptyStateView(
                    title: "Workout not found",
                    message: "It may have been deleted.",
                    systemImage: "questionmark.folder"
                )
            }
        }
        .background(Color.background)
        .toolbar {
            if viewModel.workout != nil {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit", action: viewModel.handleEditTapped)
                }

                ToolbarItem(placement: .primaryAction) {
                    Menu("More", systemImage: "ellipsis") {
                        Button("Duplicate", systemImage: "plus.square.on.square", action: viewModel.handleDuplicateTapped)
                        Button("Delete", systemImage: "trash", role: .destructive, action: viewModel.handleDeleteTapped)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isEditorPresented) {
            WorkoutTemplateEditorSheet(workout: viewModel.workout)
        }
        .confirmationDialog(
            "Delete \(viewModel.workout?.name ?? "workout")?",
            isPresented: $viewModel.isConfirmingDeletion,
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
    }
}

// MARK: - Previews
#Preview {
    let repository = MockedWorkoutRepository(templates: [.mockedWorkoutTemplate])
    NavigationStack {
        WorkoutTemplateDetailView(viewModel: WorkoutTemplateDetailViewModel(
            workoutId: Workout.mockedWorkoutTemplate.id,
            workoutRepository: repository,
            navigationManager: WorkoutTemplatesNavigationManager()
        ))
        .task { try? await repository.loadData() }
    }
}
