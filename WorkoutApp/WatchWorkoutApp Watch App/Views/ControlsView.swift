//
//  ControlsView.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 11.05.2023.
//

import SwiftUI

struct ControlsView: View {

    // MARK: - Properties
    @Environment(WorkoutManager.self) private var workoutManager

    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            HStack(spacing: 20) {
                controlButton(
                    icon: "xmark",
                    label: "End",
                    color: .red
                ) {
                    workoutManager.endWorkout()
                }

                controlButton(
                    icon: workoutManager.running ? "pause" : "play",
                    label: workoutManager.running ? "Pause" : "Resume",
                    color: .yellow
                ) {
                    workoutManager.togglePauseWorkout()
                }
            }

            Spacer()
        }
        .scenePadding()
    }

    // MARK: - Private Methods
    @ViewBuilder
    private func controlButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
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
