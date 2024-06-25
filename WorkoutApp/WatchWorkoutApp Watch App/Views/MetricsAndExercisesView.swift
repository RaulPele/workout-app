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
        VStack(spacing: 1) {
            Color.blue
            TabView(selection: $selection) {
                MetricsView()
                    .tag(0)
                
                //            if let exercises = workoutManager.remainingExercises {
                
                ForEach(workoutManager.remainingExercises.indices, id: \.self) { index in
                    CurrentExerciseView(currentExercise: PerformedExercise(
                        id: .init(),
                        exercise: workoutManager.remainingExercises[index],
                        sets: []))
                    //                    Color.red
                    .tag(index + 1 )
                    //                        .id(workoutManager.remainingExercises.indices)
                }
                //            }
            }
            .tabViewStyle(.carousel)
            .layoutPriority(1)
        }

//        .scenePadding()
//        .navigationTitle("qweqwe")
//        .navigationBarHidden(false)
    }
}
