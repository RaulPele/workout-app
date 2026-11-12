//
//  SessionDetailView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - SessionDetailView
/// What was done in one session: totals, then every exercise with its sets.
struct SessionDetailView: View {

    // MARK: - Properties
    let viewModel: SessionDetailViewModel

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: dynamicTypeSize.isAccessibilitySize ? 150 : 96), spacing: 10)]
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let dateText = viewModel.dateText {
                    Text(dateText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                LazyVGrid(columns: columns, spacing: 10) {
                    StatTileView(value: viewModel.durationText, label: "duration", systemImage: "timer")
                    StatTileView(value: viewModel.setsText, label: "sets", systemImage: "checkmark.circle")
                    StatTileView(value: viewModel.volumeText, label: "volume", systemImage: "scalemass")
                    StatTileView(value: viewModel.heartRateText, label: "avg bpm", systemImage: "heart")
                    StatTileView(value: viewModel.activeCaloriesText, label: "active kcal", systemImage: "flame")
                }

                SectionHeaderView(title: "Exercises")

                if viewModel.session.performedExercises.isEmpty {
                    Text("No sets were logged in this session.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .cardStyle()
                } else {
                    ForEach(viewModel.session.performedExercises) { performedExercise in
                        PerformedExerciseCardView(performedExercise: performedExercise)
                    }
                }
            }
            .padding()
        }
        .background(Color.background)
        .navigationTitle(viewModel.title)
    }
}

// MARK: - Previews
#Preview {
    NavigationStack {
        SessionDetailView(viewModel: SessionDetailViewModel(session: .mocked1))
    }
}
