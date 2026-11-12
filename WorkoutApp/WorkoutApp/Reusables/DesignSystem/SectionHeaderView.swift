//
//  SectionHeaderView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - SectionHeaderView
/// A section title for scrolling card layouts, with an optional subtitle.
struct SectionHeaderView: View {

    // MARK: - Properties
    let title: String
    var subtitle: String?

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.title3)
                .bold()
                .foregroundStyle(Color.onBackground)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}
