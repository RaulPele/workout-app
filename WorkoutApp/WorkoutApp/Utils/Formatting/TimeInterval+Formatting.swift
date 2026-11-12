//
//  TimeInterval+Formatting.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import Foundation

extension TimeInterval {

    /// Minutes and seconds, e.g. "1:30". Used for rest times.
    var restFormatted: String {
        Duration.seconds(self).formatted(.time(pattern: .minuteSecond))
    }

    /// Short workout length, e.g. "52 min" or "1 hr, 5 min".
    var durationFormatted: String {
        let duration = Duration.seconds(self)
        if self < 60 {
            return duration.formatted(.units(allowed: [.seconds], width: .abbreviated))
        }
        return duration.formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
    }
}

extension Double {

    /// A weight in kilograms, e.g. "62.5 kg" or "6,240 kg".
    var kilogramsFormatted: String {
        "\(formatted(.number.precision(.fractionLength(0...1)))) kg"
    }
}
