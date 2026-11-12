//
//  ChipSelectionSectionView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - ChipSelectionSectionView
/// A titled card with a wrapping cloud of selectable chips.
struct ChipSelectionSectionView<Option: Hashable>: View {

    // MARK: - Properties
    let title: String
    var subtitle: String?
    let options: [Option]
    let label: (Option) -> String
    let isSelected: (Option) -> Bool
    let onToggle: (Option) -> Void

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.onSurface)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)

            FlowLayout {
                ForEach(options, id: \.self) { option in
                    ChipView(title: label(option), isSelected: isSelected(option)) {
                        onToggle(option)
                    }
                }
            }
        }
        .cardStyle()
    }
}
