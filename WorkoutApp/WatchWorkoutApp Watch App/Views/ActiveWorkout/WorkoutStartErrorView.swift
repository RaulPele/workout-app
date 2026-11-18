//
//  WorkoutStartErrorView.swift
//  WatchWorkoutApp Watch App
//

import SwiftUI

/// Shown in place of the workout pages when the HealthKit session fails to start.
struct WorkoutStartErrorView: View {

    // MARK: - Properties
    let message: String
    let onRetry: () -> Void
    let onCancel: () -> Void

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)

                Text("Couldn't Start Workout")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Try Again", action: onRetry)
                    .tint(Color.primaryColor)

                Button("Back", role: .cancel, action: onCancel)
            }
            .scenePadding()
        }
    }
}

// MARK: - Previews
#if DEBUG
#Preview {
    WorkoutStartErrorView(
        message: "Check that Health access is allowed for this app, then try again.",
        onRetry: {},
        onCancel: {}
    )
}
#endif
