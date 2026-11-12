//
//  ExerciseTrackingView.swift
//  WatchWorkoutApp Watch App
//

import SwiftUI
import WatchKit

struct ExerciseTrackingView: View {

    // MARK: - Properties
    @Bindable var viewModel: ActiveWorkoutViewModel
    let onFinishWorkout: () -> Void

    private var trackingVM: ExerciseTrackingViewModel {
        viewModel.exerciseTrackingViewModel
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            switch trackingVM.phase {
            case .active:
                exerciseMainView
                    .scenePadding()
                    .transition(.opacity)

            case .resting:
                RestTimerView(viewModel: trackingVM)
                    .scenePadding()
                    .transition(.opacity)

            case .exerciseComplete:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.3), value: trackingVM.phase)
        .navigationTitle(trackingVM.phase == .resting ? "" : trackingVM.exercise.name)
        .toolbar(trackingVM.phase == .resting ? .hidden : .automatic, for: .navigationBar)
        .onChange(of: trackingVM.phase) { _, newPhase in
            guard case .exerciseComplete = newPhase else { return }
            let isLast = viewModel.isLastExercise
            let performed = trackingVM.finishExercise()
            viewModel.completeExercise(performed)
            WKInterfaceDevice.current().play(.success)
            if isLast {
                onFinishWorkout()
            }
        }
        .sheet(isPresented: Bindable(trackingVM).showingLogSheet) {
            SetInputSheet(viewModel: trackingVM)
        }
        .sheet(isPresented: Bindable(trackingVM).showingSwapSheet) {
            SwapExerciseSheet(
                exercises: viewModel.remainingExercises,
                onSelect: { exercise in
                    trackingVM.showingSwapSheet = false
                    viewModel.swapExercise(with: exercise)
                }
            )
        }

    }

    // MARK: - Private Views
    @ViewBuilder
    private var exerciseMainView: some View {
        VStack(spacing: 16) {
            Text("Set \(trackingVM.currentSet) of \(trackingVM.totalSets)")
                .font(.caption)
                .foregroundStyle(.secondary)

            let canSwap = !viewModel.remainingExercises.isEmpty && trackingVM.performedSets.isEmpty

            HStack(spacing: 20) {
                if canSwap {
                    actionButton(
                        icon: "checkmark",
                        label: "End",
                        color: Color.primaryColor
                    ) {
                        trackingVM.showingLogSheet = true
                    }

                    actionButton(
                        icon: "arrow.triangle.2.circlepath",
                        label: "Swap",
                        color: .secondary
                    ) {
                        trackingVM.showingSwapSheet = true
                    }
                } else {
                    Button {
                        trackingVM.showingLogSheet = true
                    } label: {
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
private func previewTrackingView(
    workout: Workout = .mockedWorkoutTemplate,
    phase: ExercisePhase = .active,
    currentSet: Int = 1,
    performedSets: [PerformedSet] = []
) -> some View {
    let trackingVM = ExerciseTrackingViewModel(
        exercise: workout.exercises[0],
        phase: phase,
        currentSet: currentSet,
        performedSets: performedSets
    )
    let vm = ActiveWorkoutViewModel(workout: workout, exerciseTrackingViewModel: trackingVM)

    return ExerciseTrackingView(
        viewModel: vm,
        onFinishWorkout: {}
    )
    .environment(WorkoutManager(phoneCommunicator: MockedPhoneCommunicator()))
}

#Preview("Active - Set 1") {
    previewTrackingView()
}

#Preview("Active - Set 3 of 4") {
    let sets = (1...2).map { _ in
        PerformedSet(id: UUID(), set: ExerciseSet.mockedBBSquats, reps: 5, weight: 70, restTime: 90)
    }
    return previewTrackingView(
        phase: .active,
        currentSet: 3,
        performedSets: sets
    )
}

#Preview("Rest Timer") {
    let set = PerformedSet(id: UUID(), set: ExerciseSet.mockedBBBenchPress, reps: 12, weight: 60, restTime: 0)
    return previewTrackingView(
        phase: .resting,
        currentSet: 1,
        performedSets: [set]
    )
}
#endif
