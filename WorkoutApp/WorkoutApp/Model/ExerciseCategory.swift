//
//  ExerciseCategory.swift
//  WorkoutApp
//
//  Created by Raul Pele on 22.03.2026.
//

import Foundation

enum ExerciseCategory: String, Codable, CaseIterable, Hashable {
    case strength
    case stretching
    case cardio
    case powerlifting
    case plyometrics
    case strongman
    case olympicWeightlifting = "olympic weightlifting"

    // MARK: - Properties
    var displayName: String {
        switch self {
        case .olympicWeightlifting: "Olympic Weightlifting"
        default: rawValue.capitalized
        }
    }
}
