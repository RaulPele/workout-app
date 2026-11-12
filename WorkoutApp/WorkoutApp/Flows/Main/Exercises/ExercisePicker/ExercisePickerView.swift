//
//  ExercisePickerView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - ExercisePickerView
/// Pick several library exercises at once to add to a workout.
struct ExercisePickerView: View {

    // MARK: - Properties
    @State private var viewModel: ExercisePickerViewModel
    @Environment(\.dismiss) private var dismiss

    private let onAdd: ([ExerciseDefinition]) -> Void

    // MARK: - Initializers
    init(viewModel: ExercisePickerViewModel, onAdd: @escaping ([ExerciseDefinition]) -> Void) {
        self._viewModel = State(initialValue: viewModel)
        self.onAdd = onAdd
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLibraryEmpty {
                    EmptyStateView(
                        title: "Your library is empty",
                        message: "Create an exercise to add it to this workout.",
                        systemImage: "figure.strengthtraining.traditional",
                        actionTitle: "New Exercise",
                        action: { viewModel.isCreatingExercise = true }
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            if viewModel.availableMuscles.count > 1 {
                                MuscleFilterBarView(muscles: viewModel.availableMuscles, selection: $viewModel.selectedMuscle)
                            }

                            LazyVStack(spacing: 10) {
                                DashedActionCard(title: "New Exercise") {
                                    viewModel.isCreatingExercise = true
                                }

                                ForEach(viewModel.filteredDefinitions) { definition in
                                    Button {
                                        viewModel.toggle(definition)
                                    } label: {
                                        ExerciseLibraryCardView(
                                            definition: definition,
                                            accessory: viewModel.accessory(for: definition)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding([.horizontal, .bottom])
                        }
                    }
                    .overlay {
                        if viewModel.filteredDefinitions.isEmpty && !viewModel.searchText.isEmpty {
                            ContentUnavailableView.search(text: viewModel.searchText)
                        }
                    }
                }
            }
            .background(Color.background)
            .navigationTitle("Add Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !viewModel.selectedIds.isEmpty {
                    BottomActionBar(title: viewModel.addButtonTitle) {
                        onAdd(viewModel.selectedDefinitions)
                        dismiss()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.snappy, value: viewModel.selectedIds.isEmpty)
            .sheet(isPresented: $viewModel.isCreatingExercise) {
                ExerciseEditorSheet(onSaved: viewModel.handleCreated)
            }
            .task {
                await viewModel.load()
            }
        }
    }
}

// MARK: - Previews
#Preview {
    ExercisePickerView(
        viewModel: ExercisePickerViewModel(
            libraryRepository: MockedUserExerciseLibraryRepository(seed: [.mockedBBBenchPress, .mockedBBSquats, .mockedPullUp]),
            definitionIdsInWorkout: [ExerciseDefinition.mockedBBSquats.id]
        ),
        onAdd: { _ in }
    )
}
