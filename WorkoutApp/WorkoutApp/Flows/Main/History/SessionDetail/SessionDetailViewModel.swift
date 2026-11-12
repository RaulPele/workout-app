//
//  SessionDetailViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import Foundation
import Observation

// MARK: - SessionDetailViewModel
@MainActor
@Observable
final class SessionDetailViewModel {

    // MARK: - Properties
    let session: WorkoutSession

    var title: String {
        session.workoutTemplate.name
    }

    /// "Tue, 10 Nov · 18:05 – 18:57"
    var dateText: String? {
        guard let start = session.startDate else { return nil }
        let day = start.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
        guard let end = session.endDate else {
            return "\(day) · \(start.formatted(date: .omitted, time: .shortened))"
        }
        return "\(day) · \((start..<max(start, end)).formatted(.interval.hour().minute()))"
    }

    var durationText: String {
        session.resolvedDuration?.durationFormatted ?? "–"
    }

    var setsText: String {
        "\(session.completedSetCount)/\(session.plannedSetCount)"
    }

    var volumeText: String {
        session.volume > 0 ? session.volume.kilogramsFormatted : "–"
    }

    var heartRateText: String? {
        session.averageHeartRate.map { "\($0)" }
    }

    var activeCaloriesText: String? {
        session.activeCalories.map { "\($0)" }
    }

    // MARK: - Initializers
    init(session: WorkoutSession) {
        self.session = session
    }
}
