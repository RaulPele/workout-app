//
//  WeekSummary.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import Foundation

// MARK: - WeekSummary
/// Totals for the sessions logged in the current week.
struct WeekSummary: Equatable {
    let workoutCount: Int
    let totalDuration: TimeInterval
    let totalSets: Int

    init(sessions: [WorkoutSession], now: Date = .now, calendar: Calendar = .current) {
        let thisWeek = sessions.filter { calendar.isDate($0.sortDate, equalTo: now, toGranularity: .weekOfYear) }
        workoutCount = thisWeek.count
        totalDuration = thisWeek.compactMap(\.resolvedDuration).reduce(0, +)
        totalSets = thisWeek.reduce(0) { $0 + $1.completedSetCount }
    }
}
