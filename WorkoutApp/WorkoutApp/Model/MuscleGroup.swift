//
//  MuscleGroup.swift
//  WorkoutApp
//
//  Created by Raul Pele on 22.03.2026.
//

import Foundation

enum MuscleGroup: String, Codable, CaseIterable, Hashable {
    case abdominals
    case abductors
    case adductors
    case biceps
    case calves
    case chest
    case forearms
    case glutes
    case hamstrings
    case lats
    case lowerBack = "lower back"
    case middleBack = "middle back"
    case neck
    case quadriceps
    case shoulders
    case traps
    case triceps

    // MARK: - Properties
    var displayName: String {
        switch self {
        case .lowerBack: "Lower Back"
        case .middleBack: "Middle Back"
        default: rawValue.capitalized
        }
    }
}
