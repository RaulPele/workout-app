//
//  DashedActionCard.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - DashedActionCard
/// A card-sized button with a dashed outline, used for "add" actions at the end of a stack.
struct DashedActionCard: View {

    // MARK: - Properties
    let title: String
    var systemImage: String = "plus"
    let action: () -> Void

    // MARK: - Body
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(Color.primaryColor)
                .frame(maxWidth: .infinity)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: CardStyle.cornerRadius, style: .continuous)
                        .strokeBorder(
                            Color.primaryColor.opacity(0.5),
                            style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                        )
                }
                .contentShape(.rect(cornerRadius: CardStyle.cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews
#Preview {
    DashedActionCard(title: "Add Exercises") {}
        .padding()
        .background(Color.background)
}
