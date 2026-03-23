//
//  ExerciseLevel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 22.03.2026.
//

import Foundation

enum ExerciseLevel: String, Codable, CaseIterable, Hashable {
    case beginner
    case intermediate
    case expert

    // MARK: - Properties
    var displayName: String {
        rawValue.capitalized
    }
}
