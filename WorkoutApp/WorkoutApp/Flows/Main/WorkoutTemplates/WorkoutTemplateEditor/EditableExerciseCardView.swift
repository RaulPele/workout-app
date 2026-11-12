//
//  EditableExerciseCardView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - EditableExerciseCardView
/// An exercise in the workout editor. Collapsed it shows the targets; tapping expands it in place
/// to edit sets, reps and rest. The leading handle drags it within a `ReorderableVStack`.
struct EditableExerciseCardView: View {

    // MARK: - Properties
    @Binding var draft: ExerciseDraft
    let isExpanded: Bool
    let onToggle: () -> Void
    let onRemove: () -> Void

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 44)
                    .contentShape(.rect)
                    .reorderDragHandle()
                    .accessibilityHidden(true)

                Button(action: onToggle) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(draft.definition.name)
                                .font(.headline)
                                .foregroundStyle(Color.onSurface)
                                .multilineTextAlignment(.leading)

                            if isExpanded {
                                if let summary = draft.definition.detailSummary {
                                    Text(summary)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            } else {
                                FlowLayout(spacing: 6) {
                                    PillView(text: draft.exercise.targetSummary)
                                    PillView(text: draft.exercise.restSummary, systemImage: "timer")
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "chevron.down")
                            .font(.footnote.bold())
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(draft.definition.name), \(draft.exercise.targetSummary), \(draft.exercise.restSummary)")
                .accessibilityHint(isExpanded ? "Collapses the targets" : "Edits sets, reps and rest")
            }

            if isExpanded {
                HStack(alignment: .top) {
                    StepperField(label: "Sets", value: $draft.sets, range: 1...20)
                        .frame(maxWidth: .infinity)
                    StepperField(label: "Reps", value: $draft.reps, range: 1...100)
                        .frame(maxWidth: .infinity)
                }

                StepperField(
                    label: "Rest",
                    value: $draft.restSeconds,
                    range: 0...600,
                    step: 15,
                    formatValue: { TimeInterval($0).restFormatted }
                )
                .frame(maxWidth: .infinity)

                Button("Remove from Workout", systemImage: "trash", role: .destructive, action: onRemove)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
            }
        }
        .cardStyle()
        .overlay {
            RoundedRectangle(cornerRadius: CardStyle.cornerRadius, style: .continuous)
                .strokeBorder(Color.primaryColor.opacity(isExpanded ? 0.6 : 0), lineWidth: 1.5)
        }
        .accessibilityAction(named: "Remove from Workout", onRemove)
    }
}

// MARK: - Previews
#Preview {
    @Previewable @State var draft = ExerciseDraft(exercise: .mockedBBBenchPress)
    @Previewable @State var isExpanded = true

    VStack {
        EditableExerciseCardView(draft: $draft, isExpanded: isExpanded, onToggle: { isExpanded.toggle() }, onRemove: {})
        EditableExerciseCardView(draft: .constant(ExerciseDraft(exercise: .mockedBBSquats)), isExpanded: false, onToggle: {}, onRemove: {})
    }
    .padding()
    .background(Color.background)
}
