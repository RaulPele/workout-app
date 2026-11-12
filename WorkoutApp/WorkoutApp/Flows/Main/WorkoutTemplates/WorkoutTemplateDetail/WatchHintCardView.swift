//
//  WatchHintCardView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - WatchHintCardView
/// Tells you where to run a workout. This is where a phone "Start" button goes once logging comes to iPhone.
struct WatchHintCardView: View {

    // MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "applewatch")
                .font(.title2)
                .foregroundStyle(Color.primaryColor)
                .accessibilityHidden(true)

            Text("Start this workout from your Apple Watch.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .cardStyle(background: Color.primaryColor.opacity(0.08))
    }
}
