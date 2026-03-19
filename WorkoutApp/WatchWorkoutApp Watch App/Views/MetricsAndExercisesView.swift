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
    @Environment(WorkoutManager.self) private var workoutManager

    var body: some View {
        VStack(spacing: 1) {
            TabView(selection: $selection) {
                MetricsView()
                    .tag(0)

                ForEach(Array(workoutManager.remainingExercises.enumerated()), id: \.element.id) { offset, exercise in
                    CurrentExerciseView(currentExercise: PerformedExercise(
                        id: .init(),
                        exercise: exercise,
                        sets: []))
                    .tag(offset + 1)
                }
                
            }
            .tabViewStyle(.carousel)
            .layoutPriority(1)
        }
    }
}
