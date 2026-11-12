//
//  BottomActionBar.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - BottomActionBar
/// A floating Liquid Glass button pinned to the bottom of a screen via `safeAreaInset`.
struct BottomActionBar: View {

    // MARK: - Properties
    let title: String
    let action: () -> Void

    // MARK: - Body
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

// MARK: - Previews
#Preview {
    Color.background
        .ignoresSafeArea()
        .safeAreaInset(edge: .bottom) {
            BottomActionBar(title: "Add 3 Exercises") {}
        }
}
