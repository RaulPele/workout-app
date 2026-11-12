//
//  ExerciseLibraryCardView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - ExerciseLibraryCardView
/// A library exercise as a card: name, muscles and equipment, plus an optional trailing accessory.
struct ExerciseLibraryCardView: View {

    // MARK: - Accessory
    enum Accessory: Equatable {
        case none
        case selection(isSelected: Bool)
        case tag(String)
    }

    // MARK: - Properties
    let definition: ExerciseDefinition
    var accessory: Accessory = .none

    private var isSelected: Bool {
        accessory == .selection(isSelected: true)
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(definition.name)
                    .font(.headline)
                    .foregroundStyle(Color.onSurface)

                Text(definition.detailSummary ?? "No muscles or equipment")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            switch accessory {
            case .none:
                EmptyView()
            case .selection(let isSelected):
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.primaryColor : Color.secondary)
                    .contentTransition(.symbolEffect(.replace))
                    .accessibilityHidden(true)
            case .tag(let text):
                PillView(text: text, isMonospaced: false)
            }
        }
        .cardStyle()
        .overlay {
            RoundedRectangle(cornerRadius: CardStyle.cornerRadius, style: .continuous)
                .strokeBorder(Color.primaryColor, lineWidth: isSelected ? 2 : 0)
        }
        .animation(.snappy, value: accessory)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Previews
#Preview {
    VStack {
        ExerciseLibraryCardView(definition: .mockedBBBenchPress)
        ExerciseLibraryCardView(definition: .mockedPullUp, accessory: .selection(isSelected: true))
        ExerciseLibraryCardView(definition: .mockedBBSquats, accessory: .tag("In workout"))
    }
    .padding()
    .background(Color.background)
}
