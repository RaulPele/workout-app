//
//  SessionSection.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import Foundation

// MARK: - SessionSection
/// Sessions grouped under a relative date heading (Today, Yesterday, This Week, …).
struct SessionSection: Identifiable {
    let id: String
    let title: String
    let sessions: [WorkoutSession]

    static func grouped(_ sessions: [WorkoutSession], now: Date = .now, calendar: Calendar = .current) -> [SessionSection] {
        var today: [WorkoutSession] = []
        var yesterday: [WorkoutSession] = []
        var thisWeek: [WorkoutSession] = []
        var thisMonth: [WorkoutSession] = []
        var earlier: [WorkoutSession] = []

        for session in sessions.sorted(by: { $0.sortDate > $1.sortDate }) {
            let date = session.sortDate
            if calendar.isDateInToday(date) {
                today.append(session)
            } else if calendar.isDateInYesterday(date) {
                yesterday.append(session)
            } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
                thisWeek.append(session)
            } else if calendar.isDate(date, equalTo: now, toGranularity: .month) {
                thisMonth.append(session)
            } else {
                earlier.append(session)
            }
        }

        return [
            SessionSection(id: "today", title: "Today", sessions: today),
            SessionSection(id: "yesterday", title: "Yesterday", sessions: yesterday),
            SessionSection(id: "thisWeek", title: "This Week", sessions: thisWeek),
            SessionSection(id: "thisMonth", title: "This Month", sessions: thisMonth),
            SessionSection(id: "earlier", title: "Earlier", sessions: earlier)
        ].filter { !$0.sessions.isEmpty }
    }
}
