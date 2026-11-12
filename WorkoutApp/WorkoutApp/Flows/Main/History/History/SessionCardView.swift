//
//  SessionCardView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - SessionCardView
/// A logged session as a card: a date tile, the workout name, start time and stat pills.
struct SessionCardView: View {

    // MARK: - Properties
    let session: WorkoutSession

    // MARK: - Body
    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 0) {
                Text(session.sortDate, format: .dateTime.day())
                    .font(.title2.monospaced())
                    .bold()
                Text(session.sortDate, format: .dateTime.weekday(.abbreviated))
                    .font(.caption)
                    .textCase(.uppercase)
            }
            .foregroundStyle(Color.primaryColor)
            .frame(minWidth: 52, minHeight: 56)
            .background(Color.primaryColor.opacity(0.1), in: .rect(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.workoutTemplate.name)
                        .font(.headline)
                        .foregroundStyle(Color.onSurface)
                        .lineLimit(2)

                    if let startDate = session.startDate {
                        Text(startDate, format: .dateTime.hour().minute())
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                FlowLayout(spacing: 6) {
                    if let duration = session.resolvedDuration {
                        PillView(text: duration.durationFormatted, systemImage: "timer")
                    }
                    PillView(text: "\(session.completedSetCount) sets")
                    if session.volume > 0 {
                        PillView(text: session.volume.kilogramsFormatted)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.footnote.bold())
                .foregroundStyle(.tertiary)
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Previews
#Preview {
    VStack {
        SessionCardView(session: .mocked1)
        SessionCardView(session: .mocked2)
    }
    .padding()
    .background(Color.background)
}
