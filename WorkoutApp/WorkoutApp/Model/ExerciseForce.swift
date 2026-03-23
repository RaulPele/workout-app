//
//  ExerciseForce.swift
//  WorkoutApp
//
//  Created by Raul Pele on 22.03.2026.
//

import Foundation

enum ExerciseForce: String, Codable, Hashable {
    case push
    case pull
    case `static`

    // MARK: - Properties
    var displayName: String {
        rawValue.capitalized
    }
}
