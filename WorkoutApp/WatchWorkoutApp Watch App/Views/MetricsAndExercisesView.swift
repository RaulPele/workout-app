//
//  MetricsAndExercisesView.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 29.05.2023.
//

import SwiftUI

struct MetricsAndExercisesView: View {
    
    enum Tab {
        case metrics
        case exercise1
        case exercise2
    }
    
    @State var selection: Int = 0
    @State var availableExercises = [Exercise]()
    @EnvironmentObject var workoutManager: WorkoutManager
    
    
    var body: some View {
        TabView(selection: $selection) {
            MetricsView()
                .tag(0)

//            if let exercises = workoutManager.remainingExercises {
            ForEach(workoutManager.remainingExercises.indices, id: \.self) { index in
                    CurrentExerciseView(currentExercise: PerformedExercise(
                        id: .init(),
                        exercise: workoutManager.remainingExercises[index],
                        sets: []))
                        .tag(index + 1 )
                        .id(workoutManager.remainingExercises.indices)
                }
//            }
        }
        .tabViewStyle(.carousel)
//        .navigationTitle("qweqwe")
//        .navigationBarHidden(false)
    }
}
