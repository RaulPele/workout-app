//
//  WeekSummaryValueView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - WeekSummaryValueView
/// One number with a label inside the week summary card.
struct WeekSummaryValueView: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.title3.monospaced())
                .bold()
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .foregroundStyle(Color.onSurface)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
