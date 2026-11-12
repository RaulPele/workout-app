//
//  EmptyStateView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - EmptyStateView
/// Shared empty and error state: icon, title, one-line message and an optional action.
struct EmptyStateView: View {

    // MARK: - Properties
    let title: String
    let message: String
    let systemImage: String
    var actionTitle: String?
    var action: (() -> Void)?

    // MARK: - Body
    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        } actions: {
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
            }
        }
    }
}

// MARK: - Previews
#Preview {
    EmptyStateView(
        title: "Build your first workout",
        message: "Workouts you create here sync to your Apple Watch.",
        systemImage: "dumbbell",
        actionTitle: "New Workout",
        action: {}
    )
    .background(Color.background)
}
