//
//  SetTableView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - SetTableView
/// Logged sets as a compact table: set number, weight × reps, rest.
struct SetTableView: View {

    // MARK: - Properties
    let sets: [PerformedSet]

    // MARK: - Body
    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
            GridRow {
                Text("Set")
                Text("Weight × reps")
                Text("Rest")
                    .gridColumnAlignment(.trailing)
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            ForEach(sets.enumerated(), id: \.offset) { index, performedSet in
                GridRow {
                    Text("\(index + 1)")
                        .foregroundStyle(Color.primaryColor)
                        .bold()

                    Text(Self.loadText(for: performedSet))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(index == sets.count - 1 || performedSet.restTime <= 0 ? "–" : performedSet.restTime.restFormatted)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .font(.subheadline.monospacedDigit())
    }

    // MARK: - Formatting
    /// "60 kg × 6", or just "12 reps" when no weight was logged.
    static func loadText(for performedSet: PerformedSet) -> String {
        guard performedSet.weight > 0 else {
            return "\(performedSet.reps) reps"
        }
        return "\(performedSet.weight.kilogramsFormatted) × \(performedSet.reps)"
    }
}
