//
//  ChipView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - ChipView
/// A tappable capsule used for filters and multi/single-select pickers.
struct ChipView: View {

    // MARK: - Properties
    let title: String
    var isSelected: Bool = false
    var unselectedBackground: Color = .background
    let action: () -> Void

    // MARK: - Body
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundStyle(isSelected ? Color.buttonForeground : Color.onSurface)
                .background(isSelected ? Color.primaryColor : unselectedBackground, in: .capsule)
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .animation(.snappy, value: isSelected)
        .sensoryFeedback(.selection, trigger: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Previews
#Preview {
    FlowLayout {
        ChipView(title: "Chest", isSelected: true) {}
        ChipView(title: "Triceps") {}
        ChipView(title: "Shoulders") {}
    }
    .padding()
    .background(Color.surface)
}
