//
//  CurrentExerciseView.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 29.05.2023.
//

import SwiftUI

extension CurrentExerciseView {

    @MainActor @Observable
    class ViewModel {

        var currentExercise: PerformedExercise
        var reps = ClosedRange(uncheckedBounds: (0, 500))
        var weights = ClosedRange(uncheckedBounds: (0, 500))
        var currentRepCount: Int = 0
        var currentWeight: Int = 0
        var currentSet: Int = 1
        var shouldShowMetrics = true
        var shouldShowConfirmation = false
        var currentRestTime: TimeInterval = 0
        var startDate = Date.now
        var shouldShowRestView: Bool = false
        var workoutManager: WorkoutManager?

        @ObservationIgnored private var restTimerTask: Task<Void, Never>?

        private let onFinished: () -> Void

        init(currentExercise: PerformedExercise, onFinished: @escaping () -> Void) {
            self.currentExercise = currentExercise
            self.onFinished = onFinished
        }

        var hasFinishedExercise: Bool {
            return currentSet > currentExercise.exercise.numberOfSets
        }

        var lastPerformedSet: PerformedSet?

        // MARK: - Handlers
        func handleEndSetTapped() {
            currentSet += 1
            lastPerformedSet = PerformedSet(
                id: .init(),
                set: currentExercise.exercise.setData,
                reps: currentRepCount,
                weight: Double(currentWeight),
                restTime: 0
            )

            shouldShowConfirmation = true
            Task {
                try? await Task.sleep(for: .seconds(2))
                shouldShowConfirmation = false

                if hasFinishedExercise {
                    print("Finished exercise!")
                    currentExercise.sets.append(lastPerformedSet!)
                    workoutManager?.addPerformedExercise(currentExercise)
                    onFinished()
                    if let workoutManager, workoutManager.remainingExercises.isEmpty {
                        workoutManager.endWorkout()
                    }
                } else {
                    startRest()
                }
            }
        }

        func startRest() {
            shouldShowRestView = true
            startDate = Date.now
            currentRestTime = 0
            restTimerTask = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(1))
                    guard !Task.isCancelled else { break }
                    currentRestTime = Date.now.timeIntervalSince(startDate)
                    if currentRestTime >= currentExercise.exercise.restBetweenSets {
                        endRest()
                        break
                    }
                }
            }
        }

        func endRest() {
            restTimerTask?.cancel()
            restTimerTask = nil
            lastPerformedSet?.restTime = currentRestTime
            currentExercise.sets.append(lastPerformedSet!)
            shouldShowRestView = false
        }
    }
}

struct CurrentExerciseView: View {

    @State private var viewModel: ViewModel
    @Environment(WorkoutManager.self) private var workoutManager

    init(currentExercise: PerformedExercise) {
        _viewModel = .init(wrappedValue: ViewModel(currentExercise: currentExercise, onFinished: {}))
    }

    var body: some View {
        VStack {
            Text("Set: \(viewModel.currentExercise.sets.count + 1) / \(viewModel.currentExercise.exercise.numberOfSets)")
            HStack {
            }
            .padding(.vertical)

            Spacer()
            Button {
                viewModel.handleEndSetTapped()
            } label: {
                Text("End set")
            }
            .buttonStyle(.bordered)
            .tint(Color.primaryColor)
        }
        .overlay {
            endSetConfirmationView
        }
        .overlay {
            restTimeView
        }
        .navigationTitle(viewModel.currentExercise.exercise.name)
        .scenePadding()
        .onAppear {
            viewModel.workoutManager = workoutManager
        }
    }

    @ViewBuilder
    private var endSetConfirmationView: some View {
        if viewModel.shouldShowConfirmation {
            ZStack {
                Color.black

                VStack {
                    Text(viewModel.hasFinishedExercise ? "Exercise finished! " : "Set \(viewModel.currentSet - 1)")
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.primaryColor)
                }
                .font(.title)
            }
            .transition(.opacity.animation(.default))
        }
    }

    @ViewBuilder
    private var restTimeView: some View {
        if viewModel.shouldShowRestView {
            ZStack {
                Color.black

                VStack {
                    ElapsedTimeView(elapsedTime: viewModel.currentRestTime, showSubseconds: false)

                    Button {
                        viewModel.endRest()
                    } label: {
                        Text("End rest")
                    }
                    .tint(.primaryColor)
                }
            }
        }
    }
}
