//
//  CurrentExerciseView.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 29.05.2023.
//

import SwiftUI

struct CurrentExerciseView: View {
    
    @State var currentExercise: PerformedExercise
    @State var reps = ClosedRange(uncheckedBounds: (0, 500))
    @State var weights = ClosedRange(uncheckedBounds: (0, 500))
    @State var currentRepCount: Int = 0
    @State var currentWeight: Int = 0
    @State var shouldShowMetrics = true
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        VStack {
            Text("Set: \(currentExercise.sets.count + 1) / \(currentExercise.exercise.numberOfSets)")
                HStack {
                    Picker("Reps", selection: $currentRepCount) {
                        ForEach(reps, id: \.self) { rep in
                            Text("\(rep) reps")
                        }
                    }
                    
                    .pickerStyle(.wheel)
                    
                    Picker("Weight", selection: $currentWeight) {
                        ForEach(weights, id: \.self) { weight in
                            Text("\(weight) kg")
                        }
                    }
                    .pickerStyle(.wheel)
                    
                }
                .padding(.vertical)
//            }
            
            Spacer()
            Button {
                withAnimation {
                    shouldShowMetrics.toggle()
                }
            } label: {
                Text("End set")
            }
            .buttonStyle(.bordered)
            .tint(Color.primaryColor)
        }
        .scenePadding()
        .navigationTitle(currentExercise.exercise.name)
    }
}

