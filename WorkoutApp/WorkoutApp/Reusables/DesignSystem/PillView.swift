//
//  PillView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - PillView
/// A small capsule label, used for targets ("3 × 10"), rest times and stats.
struct PillView: View {

    // MARK: - Style
    enum Style {
        case neutral
        case accent
    }

    // MARK: - Properties
    let text: String
    var systemImage: String?
    var style: Style = .neutral
    /// Monospaced for numbers ("3 × 10", "1:30"); turn off for words like muscle names.
    var isMonospaced = true

    // MARK: - Body
    var body: some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .imageScale(.small)
            }
            Text(text)
                .monospacedDigit()
        }
        .font(isMonospaced ? .caption.monospaced() : .caption)
        .foregroundStyle(style == .accent ? Color.primaryColor : Color.onSurface)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(style == .accent ? Color.primaryColor.opacity(0.12) : Color.background, in: .capsule)
    }
}

// MARK: - Previews
#Preview {
    HStack {
        PillView(text: "3 × 10")
        PillView(text: "1:30 rest", systemImage: "timer")
        PillView(text: "Chest", style: .accent, isMonospaced: false)
    }
    .padding()
    .background(Color.surface)
}
