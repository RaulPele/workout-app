//
//  Date+Extensions.swift
//  WatchWorkoutApp Watch App
//

import Foundation

extension Date {
    func toMMMdd() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, HH:mm"
        return dateFormatter.string(from: self)
    }
}
