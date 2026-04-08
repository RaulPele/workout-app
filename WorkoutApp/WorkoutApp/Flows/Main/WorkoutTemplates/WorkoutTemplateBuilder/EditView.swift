//
//  EditView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 31.05.2023.
//

import SwiftUI

struct EditView: View {

    // MARK: - ViewModel
    @MainActor
    @Observable class ViewModel {
        let exercise: Exercise

        var setsText: String
        var repsText: String
        var restSeconds: Int

        var isEditingRestTime = false
        var editMinutes: String = ""
        var editSeconds: String = ""

        // MARK: - Initializers
        init(exercise: Exercise) {
            self.exercise = exercise
            self.setsText = String(exercise.numberOfSets)
            self.repsText = String(exercise.setData.reps)
            self.restSeconds = Int(exercise.restBetweenSets)
        }

        // MARK: - Methods
        func enterRestTimeEditMode() {
            editMinutes = String(restSeconds / 60)
            editSeconds = String(restSeconds % 60)
            isEditingRestTime = true
        }

        func commitRestTimeEdit() {
            let minutes = Int(editMinutes) ?? 0
            let seconds = Int(editSeconds) ?? 0
            restSeconds = max(0, min(minutes * 60 + seconds, 600))
            isEditingRestTime = false
        }

        func buildEditedExercise() -> Exercise {
            Exercise(
                id: exercise.id,
                definition: exercise.definition,
                numberOfSets: Int(setsText) ?? 0,
                setData: .init(id: exercise.setData.id, reps: Int(repsText) ?? 0),
                restBetweenSets: TimeInterval(restSeconds)
            )
        }
    }

    // MARK: - Properties
    @State private var viewModel: ViewModel
    private let onFinishedEditing: (Exercise) -> Void
    @Environment(\.dismiss) private var dismiss

    init(exercise: Exercise, onFinishedEditing: @escaping (Exercise) -> Void) {
        self.onFinishedEditing = onFinishedEditing
        _viewModel = .init(wrappedValue: ViewModel(exercise: exercise))
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    exerciseHeader
                    setsAndRepsCard
                    restTimeCard
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.background)
            .navigationTitle("Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.isEditingRestTime {
                            viewModel.commitRestTimeEdit()
                        }
                        onFinishedEditing(viewModel.buildEditedExercise())
                        dismiss()
                    }
                    .bold()
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil, from: nil, for: nil
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Exercise Header
private extension EditView {
    var exerciseHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.exercise.name)
                .font(.title2)
                .bold()
                .foregroundStyle(Color.onBackground)

            exerciseInfoBadges
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    var exerciseInfoBadges: some View {
        let definition = viewModel.exercise.definition
        let hasBadges = !definition.primaryMuscles.isEmpty || definition.equipment != nil

        if hasBadges {
            HStack(spacing: 8) {
                ForEach(definition.primaryMuscles, id: \.self) { muscle in
                    ExerciseInfoBadge(text: muscle.displayName, color: .primaryColor)
                }

                if let equipment = definition.equipment {
                    ExerciseInfoBadge(text: equipment.displayName, color: .secondary)
                }

                ExerciseInfoBadge(
                    text: definition.level.displayName,
                    color: levelColor(definition.level)
                )
            }
        }
    }

    func levelColor(_ level: ExerciseLevel) -> Color {
        switch level {
        case .beginner: .green
        case .intermediate: .orange
        case .expert: .red
        }
    }
}

// MARK: - Sets & Reps Card
private extension EditView {
    var setsAndRepsCard: some View {
        sectionCard(icon: "repeat", title: "Sets & Reps") {
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Sets")
                        .font(.caption)
                        .foregroundStyle(Color.onBackground.opacity(0.6))

                    AppTextField(
                        "0",
                        text: $viewModel.setsText,
                        keyboardType: .numberPad,
                        textAlignment: .center,
                        digitsOnly: true
                    )
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 8) {
                    Text("Reps")
                        .font(.caption)
                        .foregroundStyle(Color.onBackground.opacity(0.6))

                    AppTextField(
                        "0",
                        text: $viewModel.repsText,
                        keyboardType: .numberPad,
                        textAlignment: .center,
                        digitsOnly: true
                    )
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Rest Time Card
private extension EditView {
    var restTimeCard: some View {
        sectionCard(icon: "timer", title: "Rest Between Sets") {
            if viewModel.isEditingRestTime {
                restTimeEditMode
            } else {
                StepperField(
                    label: "Rest",
                    value: $viewModel.restSeconds,
                    range: 0...600,
                    step: 15,
                    formatValue: { seconds in
                        let m = seconds / 60
                        let s = seconds % 60
                        if m > 0 && s > 0 { return "\(m)m \(s)s" }
                        if m > 0 { return "\(m)m" }
                        return "\(s)s"
                    },
                    onValueTapped: {
                        viewModel.enterRestTimeEditMode()
                    }
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isEditingRestTime)
    }

    var restTimeEditMode: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                AppTextField(
                    "0",
                    text: $viewModel.editMinutes,
                    keyboardType: .numberPad,
                    textAlignment: .center,
                    digitsOnly: true
                )
                .frame(width: 60)

                Text("min")
                    .font(.subheadline)
                    .foregroundStyle(Color.onBackground.opacity(0.6))

                AppTextField(
                    "0",
                    text: $viewModel.editSeconds,
                    keyboardType: .numberPad,
                    textAlignment: .center,
                    digitsOnly: true
                )
                .frame(width: 60)

                Text("sec")
                    .font(.subheadline)
                    .foregroundStyle(Color.onBackground.opacity(0.6))
            }

            Button {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
                viewModel.commitRestTimeEdit()
            } label: {
                Text("Apply")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(Color.primaryColor)
            }
        }
    }
}

// MARK: - Section Card
private extension EditView {
    func sectionCard(icon: String, title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(Color.onBackground)

            content()
                .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.surface)
        .clipShape(.rect(cornerRadius: 14))
        .shadow(color: Color.onBackground.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Exercise Info Badge
private struct ExerciseInfoBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .bold()
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(.capsule)
    }
}

// MARK: - Preview
#Preview {
    EditView(exercise: .mockedBBSquats, onFinishedEditing: { _ in })
}
