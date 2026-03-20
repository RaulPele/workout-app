//
//  WorkoutDetailsViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 04.05.2023.
//

import Foundation

extension WorkoutDetails {

    @Observable
    @MainActor
    class ViewModel {

        // MARK: - Properties
        let session: WorkoutSession

        var sessionTitle: String {
            session.title ?? session.workoutTemplate.name
        }

        var templateName: String {
            session.workoutTemplate.name
        }

        var sessionDateFormatted: String? {
            session.startDate?.formatted(date: .abbreviated, time: .omitted)
        }

        var sessionTimeRange: String? {
            guard let start = session.startDate,
                  let end = session.endDate else { return nil }
            let startFormatted = start.formatted(date: .omitted, time: .shortened)
            let endFormatted = end.formatted(date: .omitted, time: .shortened)
            return "\(startFormatted) - \(endFormatted)"
        }

        var durationFormatted: String {
            guard let duration = session.duration else { return "--" }
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .abbreviated
            return formatter.string(from: duration) ?? "--"
        }

        var averageHeartRateFormatted: String {
            guard let hr = session.averageHeartRate else { return "--" }
            return "\(hr) BPM"
        }

        var activeCaloriesFormatted: String {
            guard let cal = session.activeCalories else { return "--" }
            return "\(cal) kcal"
        }

        var totalCaloriesFormatted: String {
            guard let cal = session.totalCalories else { return "--" }
            return "\(cal) kcal"
        }

        // MARK: - Initializers
        init(session: WorkoutSession) {
            self.session = session
        }
    }
}
