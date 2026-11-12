//
//  ExerciseLibraryView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - ExerciseLibraryView
/// The Exercises tab: your exercise library, grouped by muscle, with search and a muscle filter.
struct ExerciseLibraryView: View {

    // MARK: - Properties
    @Bindable var viewModel: ExerciseLibraryViewModel

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if viewModel.availableMuscles.count > 1 {
                    MuscleFilterBarView(muscles: viewModel.availableMuscles, selection: $viewModel.selectedMuscle)
                }

                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.sections) { section in
                        SectionHeaderView(title: section.title)

                        ForEach(section.definitions) { definition in
                            ExerciseLibraryRowButton(
                                definition: definition,
                                onEdit: { viewModel.handleExerciseTapped(definition) },
                                onDelete: { viewModel.handleDeleteTapped(definition) }
                            )
                        }
                    }
                }
                .padding([.horizontal, .bottom])
            }
        }
        .background(Color.background)
        .overlay {
            if viewModel.isLibraryEmpty {
                EmptyStateView(
                    title: "Add your first exercise",
                    message: "Exercises are the building blocks of your workouts.",
                    systemImage: "figure.strengthtraining.traditional",
                    actionTitle: "New Exercise",
                    action: viewModel.handleNewExerciseTapped
                )
            } else if viewModel.sections.isEmpty && viewModel.hasLoaded {
                ContentUnavailableView.search(text: viewModel.searchText)
            }
        }
        .animation(.snappy, value: viewModel.selectedMuscle)
        .navigationTitle("Exercises")
        .searchable(text: $viewModel.searchText, prompt: "Search exercises")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New Exercise", systemImage: "plus", action: viewModel.handleNewExerciseTapped)
            }
        }
        .refreshable {
            await viewModel.load()
        }
        .sheet(item: $viewModel.activeSheet) { sheet in
            ExerciseEditorSheet(definition: sheet.definition)
        }
        .confirmationDialog(
            "Delete \(viewModel.pendingDeletion?.name ?? "exercise")?",
            isPresented: Binding(presenting: $viewModel.pendingDeletion),
            titleVisibility: .visible
        ) {
            Button("Delete Exercise", role: .destructive, action: viewModel.confirmDeletion)
        } message: {
            Text("Workouts that use it keep their copy.")
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

// MARK: - Previews
#Preview("Populated") {
    NavigationStack {
        ExerciseLibraryView(viewModel: ExerciseLibraryViewModel(
            libraryRepository: MockedUserExerciseLibraryRepository(seed: [.mockedBBBenchPress, .mockedBBSquats, .mockedPullUp]),
            navigationManager: ExercisesNavigationManager()
        ))
    }
}

#Preview("Empty") {
    NavigationStack {
        ExerciseLibraryView(viewModel: ExerciseLibraryViewModel(
            libraryRepository: MockedUserExerciseLibraryRepository(),
            navigationManager: ExercisesNavigationManager()
        ))
    }
}
