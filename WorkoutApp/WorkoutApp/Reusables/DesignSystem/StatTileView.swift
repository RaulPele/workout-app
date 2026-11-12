//
//  StatTileView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - StatTileView
/// A compact tile showing one number with a label, e.g. "17 · sets".
struct StatTileView: View {

    // MARK: - Properties
    let value: String
    let label: String
    var systemImage: String?

    // MARK: - Body
    var body: some View {
        VStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(Color.primaryColor)
            }

            Text(value)
                .font(.title3.monospaced())
                .bold()
                .monospacedDigit()
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.onSurface)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .padding(.horizontal, 8)
        .background(Color.surface, in: .rect(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Previews
#Preview {
    HStack {
        StatTileView(value: "5", label: "exercises")
        StatTileView(value: "17", label: "sets")
        StatTileView(value: "52m", label: "duration", systemImage: "timer")
    }
    .padding()
    .background(Color.background)
}
