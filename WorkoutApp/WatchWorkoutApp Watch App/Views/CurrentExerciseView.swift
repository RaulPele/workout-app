//
//  CurrentExerciseView.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 29.05.2023.
//

import SwiftUI

extension CurrentExerciseView {
    
    class ViewModel: ObservableObject {
        
        @Published var currentExercise: PerformedExercise
        @Published var reps = ClosedRange(uncheckedBounds: (0, 500))
        @Published var weights = ClosedRange(uncheckedBounds: (0, 500))
        @Published var currentRepCount: Int = 0
        @Published var currentWeight: Int = 0
        @Published var currentSet: Int = 1
        @Published var shouldShowMetrics = true
        @Published var shouldShowConfirmation = false
        @Published var currentRestTime: TimeInterval = 0
        @Published var startDate = Date.now
        @Published var shouldShowRestView: Bool = false
        var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        var workoutManager: WorkoutManager?
        
        private let onFinished: () -> Void
        
        init(currentExercise: PerformedExercise, onFinished: @escaping () -> Void) {
            self.currentExercise = currentExercise
            self.onFinished = onFinished
        }
        
        var hasFinishedExercise: Bool {
            return currentSet > currentExercise.exercise.numberOfSets
        }
        
        var lastPerformedSet: PerformedSet?
        
        //MARK: - Handlers
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                guard let self else { return }
                self.shouldShowConfirmation = false
                
                if self.hasFinishedExercise {
                    print("Finished exercise!")
                    self.currentExercise.sets.append(self.lastPerformedSet!)
                    self.workoutManager?.performedExercises.append(self.currentExercise)
    //                currentSet = 1
                    self.onFinished()
                    if let workoutManager = self.workoutManager {
                        if workoutManager.remainingExercises.isEmpty {
                            workoutManager.endWorkout()
                        }
                    }
                } else {
                    self.startRest()
                }
                
//                if !self.hasFinishedExercise {
//                    startRest()
//                }
            }
            
            
        }
        
        func startRest() {
            shouldShowRestView = true
            startDate = Date.now
            timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            
        }
        func endRest() {
            timer.upstream.connect().cancel()
            lastPerformedSet?.restTime = currentRestTime
            currentExercise.sets.append(lastPerformedSet!)
            shouldShowRestView = false
            print("CURRENT REST TIME: \(currentRestTime)")
        }
        
    }
}

struct CurrentExerciseView: View {
    
    @StateObject private var viewModel: ViewModel
    @EnvironmentObject private var workoutManager: WorkoutManager
    
    init(currentExercise: PerformedExercise) {
        _viewModel = .init(wrappedValue: ViewModel(currentExercise: currentExercise, onFinished: {}))
//        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack() {
            Text("Set: \(viewModel.currentExercise.sets.count + 1) / \(viewModel.currentExercise.exercise.numberOfSets)")
                HStack {
//                    Picker("Reps", selection: $viewModel.currentRepCount) {
//                        ForEach(viewModel.reps, id: \.self) { rep in
//                            Text("\(rep) reps")
//                        }
//                    }
//                    .pickerStyle(.wheel)

//                    Picker("Weight", selection: $viewModel.currentWeight) {
//                        ForEach(viewModel.weights, id: \.self) { weight in
//                            Text("\(weight) kg")
//                        }
//                    }
//                    .pickerStyle(.wheel)

                }
                .padding(.vertical)
//            }
            
            Spacer()
//                .layoutPriority(-1)
            Button {
                viewModel.handleEndSetTapped()
            } label: {
                Text("End set")
            }
            .buttonStyle(.bordered)
            .tint(Color.primaryColor)
//            .frame(maxHeight: .infinity, alignment: .bottom)
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
                        .foregroundColor(.primaryColor)
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
                        .onReceive(viewModel.timer) { firedDate in
                            viewModel.currentRestTime = firedDate.timeIntervalSince(viewModel.startDate)
                            if viewModel.currentRestTime >= viewModel.currentExercise.exercise.restBetweenSets {
                                viewModel.endRest()
                            }
                        }
                    
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

