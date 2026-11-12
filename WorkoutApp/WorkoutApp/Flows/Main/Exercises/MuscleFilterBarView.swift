//
//  MuscleFilterBarView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - MuscleFilterBarView
/// A horizontally scrolling row of muscle chips with an "All" option.
struct MuscleFilterBarView: View {

    // MARK: - Properties
    let muscles: [MuscleGroup]
    @Binding var selection: MuscleGroup?

    // MARK: - Body
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ChipView(title: "All", isSelected: selection == nil, unselectedBackground: .surface) {
                    selection = nil
                }

                ForEach(muscles, id: \.self) { muscle in
                    ChipView(title: muscle.displayName, isSelected: selection == muscle, unselectedBackground: .surface) {
                        selection = selection == muscle ? nil : muscle
                    }
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
}
