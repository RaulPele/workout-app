//
//  WorkoutTemplateEditorView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - WorkoutTemplateEditorView
/// Create or edit a workout template: name, exercises (reorderable, expandable to edit targets).
struct WorkoutTemplateEditorView: View {

    // MARK: - Properties
    @State private var viewModel: WorkoutTemplateEditorViewModel
    @State private var isConfirmingDiscard = false
    @Environment(\.dismiss) private var dismiss

    private let onSaved: () -> Void

    // MARK: - Initializers
    init(viewModel: WorkoutTemplateEditorViewModel, onSaved: @escaping () -> Void = {}) {
        self._viewModel = State(initialValue: viewModel)
        self.onSaved = onSaved
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    TitleTextField(
                        placeholder: "Workout name",
                        text: $viewModel.name,
                        message: viewModel.nameMessage,
                        isError: true,
                        autofocus: !viewModel.isEditing
                    )

                    SectionHeaderView(title: "Exercises", subtitle: viewModel.exercisesSubtitle)

                    ReorderableVStack(viewModel.exercises, spacing: 10, onMove: viewModel.move) { draft, isDragging in
                        EditableExerciseCardView(
                            draft: binding(for: draft),
                            isExpanded: viewModel.expandedExerciseId == draft.id,
                            onToggle: { viewModel.toggleExpanded(draft.id) },
                            onRemove: { viewModel.remove(draft.id) }
                        )
                        .scaleEffect(isDragging ? 1.03 : 1)
                        .shadow(color: .black.opacity(isDragging ? 0.15 : 0), radius: 12, y: 4)
                    }

                    DashedActionCard(title: "Add Exercises") {
                        viewModel.isPickerPresented = true
                    }

                    if let requirementMessage = viewModel.requirementMessage {
                        Text(requirementMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
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
                            if await viewModel.save() {
                                onSaved()
                                dismiss()
                            }
                        }
                    }
                    .bold()
                    .disabled(!viewModel.canSave)
                }
            }
            .sheet(isPresented: $viewModel.isPickerPresented) {
                if FeatureFlags.useRemoteExerciseCatalog {
                    CatalogExercisePickerSheet { exercise in
                        viewModel.add(exercise)
                    }
                } else {
                    ExercisePickerSheet(definitionIdsInWorkout: viewModel.definitionIdsInWorkout) { definitions in
                        viewModel.add(definitions)
                    }
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
        }
    }

    // MARK: - Bindings
    private func binding(for draft: ExerciseDraft) -> Binding<ExerciseDraft> {
        Binding(
            get: { viewModel.exercises.first { $0.id == draft.id } ?? draft },
            set: { updated in
                if let index = viewModel.exercises.firstIndex(where: { $0.id == draft.id }) {
                    viewModel.exercises[index] = updated
                }
            }
        )
    }
}

// MARK: - Previews
#Preview("New") {
    WorkoutTemplateEditorView(viewModel: WorkoutTemplateEditorViewModel(workoutRepository: MockedWorkoutRepository()))
}

#Preview("Edit") {
    WorkoutTemplateEditorView(viewModel: WorkoutTemplateEditorViewModel(
        workoutRepository: MockedWorkoutRepository(),
        workout: .mockedWorkoutTemplate
    ))
}
