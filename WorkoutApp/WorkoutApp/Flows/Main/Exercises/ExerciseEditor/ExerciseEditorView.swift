//
//  ExerciseEditorView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - ExerciseEditorView
/// Create or edit a library exercise: name, muscles and equipment.
struct ExerciseEditorView: View {

    // MARK: - Properties
    @State private var viewModel: ExerciseEditorViewModel
    @State private var isConfirmingDiscard = false
    @Environment(\.dismiss) private var dismiss

    private let onSaved: (ExerciseDefinition) -> Void
    private let equipmentOptions: [Equipment?] = [nil] + Equipment.allCases

    // MARK: - Initializers
    init(viewModel: ExerciseEditorViewModel, onSaved: @escaping (ExerciseDefinition) -> Void = { _ in }) {
        self._viewModel = State(initialValue: viewModel)
        self.onSaved = onSaved
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TitleTextField(
                        placeholder: "Exercise name",
                        text: $viewModel.name,
                        message: viewModel.nameMessage,
                        isError: true,
                        autofocus: !viewModel.isEditing
                    )

                    ChipSelectionSectionView(
                        title: "Muscles",
                        subtitle: "The main muscles it works",
                        options: MuscleGroup.allCases,
                        label: \.displayName,
                        isSelected: { viewModel.muscles.contains($0) },
                        onToggle: { viewModel.toggleMuscle($0) }
                    )

                    ChipSelectionSectionView(
                        title: "Equipment",
                        options: equipmentOptions,
                        label: { $0?.displayName ?? "None" },
                        isSelected: { viewModel.equipment == $0 },
                        onToggle: { viewModel.equipment = $0 }
                    )
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.background)
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if viewModel.hasChanges {
                            isConfirmingDiscard = true
                        } else {
                            dismiss()
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if let definition = await viewModel.save() {
                                onSaved(definition)
                                dismiss()
                            }
                        }
                    }
                    .bold()
                    .disabled(!viewModel.canSave)
                }
            }
            .confirmationDialog("Discard your changes?", isPresented: $isConfirmingDiscard, titleVisibility: .visible) {
                Button("Discard Changes", role: .destructive) {
                    dismiss()
                }
            }
            .alert("Couldn't Save", isPresented: Binding(presenting: $viewModel.errorMessage)) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .interactiveDismissDisabled(viewModel.hasChanges)
            .sensoryFeedback(.success, trigger: viewModel.isSaving) { wasSaving, isSaving in
                wasSaving && !isSaving && viewModel.errorMessage == nil
            }
            .task {
                await viewModel.load()
            }
        }
    }
}

// MARK: - Previews
#Preview("New") {
    ExerciseEditorView(viewModel: ExerciseEditorViewModel(
        libraryRepository: MockedUserExerciseLibraryRepository(seed: [.mockedBBSquats]),
        workoutRepository: MockedWorkoutRepository()
    ))
}

#Preview("Edit") {
    ExerciseEditorView(viewModel: ExerciseEditorViewModel(
        libraryRepository: MockedUserExerciseLibraryRepository(seed: [.mockedBBBenchPress]),
        workoutRepository: MockedWorkoutRepository(),
        definition: .mockedBBBenchPress
    ))
}
