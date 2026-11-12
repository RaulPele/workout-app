//
//  ExerciseTrackingView.swift
//  WatchWorkoutApp Watch App
//

import SwiftUI
import WatchKit

struct ExerciseTrackingView: View {

    // MARK: - Properties
    @Bindable var viewModel: ExerciseTrackingViewModel

    // MARK: - Body
    var body: some View {
        ZStack {
            if viewModel.exercise == nil {
                NoExercisesView()
                    .scenePadding()
            } else {
                switch viewModel.phase {
                case .active:
                    SetActionsView(viewModel: viewModel)
                        .scenePadding()
                        .transition(.opacity)

                case .resting:
                    RestTimerView(viewModel: viewModel)
                        .scenePadding()
                        .transition(.opacity)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.3), value: viewModel.phase)
        .navigationTitle(viewModel.phase == .resting ? "" : viewModel.exercise?.name ?? "")
        .toolbar(viewModel.phase == .resting ? .hidden : .automatic, for: .navigationBar)
        .sheet(isPresented: $viewModel.showingLogSheet, onDismiss: viewModel.logSheetDidDismiss) {
            SetInputSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingSwapSheet) {
            SwapExerciseSheet(
                exercises: viewModel.remainingExercises,
                onSelect: viewModel.swap(to:)
            )
        }
    }
}

// MARK: - SetActionsView
private struct SetActionsView: View {

    let viewModel: ExerciseTrackingViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Set \(viewModel.currentSet) of \(viewModel.totalSets)")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 20) {
                if viewModel.canSwap {
                    actionButton(
                        icon: "checkmark",
                        label: "End",
                        color: Color.primaryColor,
                        action: viewModel.openLogSheet
                    )

                    actionButton(
                        icon: "arrow.triangle.2.circlepath",
                        label: "Swap",
                        color: .secondary
                    ) {
                        viewModel.showingSwapSheet = true
                    }
                } else {
                    Button(action: viewModel.openLogSheet) {
                        Text("End")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .tint(Color.primaryColor)
                }
            }
        }
    }

    @ViewBuilder
    private func actionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        VStack(spacing: 6) {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.title2)
            }
            .tint(color)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - NoExercisesView
private struct NoExercisesView: View {

    var body: some View {
        VStack(spacing: 8) {
            Text("No Exercises")
                .font(.headline)

            Text("End the workout from the controls page.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - SetInputSheet
private struct SetInputSheet: View {

    @Bindable var viewModel: ExerciseTrackingViewModel
    @FocusState private var focusedField: Field?

    private enum Field {
        case reps
        case weight
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Log Set \(viewModel.currentSet)")
                .font(.headline)

            inputField(
                value: $viewModel.currentReps,
                label: "reps",
                isFocused: focusedField == .reps
            )
            .focusable()
            .focused($focusedField, equals: .reps)
            .digitalCrownRotation(
                $viewModel.currentReps,
                from: 1,
                through: 999,
                by: 1,
                sensitivity: .medium
            )
            .onTapGesture { focusedField = .reps }

            inputField(
                value: $viewModel.currentWeight,
                label: "kg",
                isFocused: focusedField == .weight
            )
            .focusable()
            .focused($focusedField, equals: .weight)
            .digitalCrownRotation(
                $viewModel.currentWeight,
                from: 0,
                through: 999,
                by: 0.5,
                sensitivity: .medium
            )
            .onTapGesture { focusedField = .weight }

            Button {
                viewModel.saveSet()
            } label: {
                Text("Save Set")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(Color.primaryColor)
        }
        .scenePadding()
        .onAppear {
            focusedField = .reps
        }
    }

    @ViewBuilder
    private func inputField(value: Binding<Double>, label: String, isFocused: Bool) -> some View {
        HStack { //TODO: what if we'd use traditional pickers instead
            Text("\(Int(value.wrappedValue))")
                .font(.title2)
                .fontWeight(.semibold)
                .fontDesign(.rounded) //TODO: unify fonts
                .monospacedDigit()
                .foregroundStyle(isFocused ? Color.primaryColor : .primary)

            Text(label)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isFocused ? Color.primaryColor.opacity(0.15) : Color.clear)
        )
    }
}

// MARK: - SwapExerciseSheet
private struct SwapExerciseSheet: View {

    let exercises: [Exercise]
    let onSelect: (Exercise) -> Void

    var body: some View {
        List(exercises) { exercise in
            Button {
                onSelect(exercise)
            } label: {
                Text(exercise.name)
            }
        }
        .navigationTitle("Swap Exercise")
    }
}

// MARK: - Previews
#if DEBUG
@MainActor
private func previewTrackingView(completedSets: Int = 0, resting: Bool = false) -> some View {
    var progress = WorkoutProgress(template: .mockedWorkoutTemplate, startDate: .now)
    for _ in 0..<completedSets {
        _ = progress.logSet(reps: 5, weight: 70, at: .now)
        progress.finishRest(at: .now)
    }
    if resting {
        _ = progress.logSet(reps: 12, weight: 60, at: .now)
    }
    let workoutManager = WorkoutManager.preview(progress: progress)

    return ExerciseTrackingView(viewModel: ExerciseTrackingViewModel(workoutManager: workoutManager))
        .environment(workoutManager)
}

#Preview("Active - Set 1") {
    previewTrackingView()
}

#Preview("Active - Set 2") {
    previewTrackingView(completedSets: 1)
}

#Preview("Rest Timer") {
    previewTrackingView(resting: true)
}
#endif
