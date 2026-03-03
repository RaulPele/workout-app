//
//  ControlsView.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 11.05.2023.
//

import SwiftUI

struct ControlsView: View {

    @Environment(WorkoutManager.self) private var workoutManager

    var body: some View {
        HStack {
            VStack {
                Button {
                    workoutManager.endWorkout()
                } label: {
                    Image(systemName: "xmark")
                }
                .tint(.red)
                .font(.title2)
                Text("End")
            }

            VStack {
                Button {
                    workoutManager.togglePauseWorkout()
                } label: {
                    Image(systemName: workoutManager.running ? "pause" : "play")
                }
                .tint(.yellow)
                .font(.title2)
                Text(workoutManager.running ? "Pause" : "Resume")
            }
        }
    }
}
