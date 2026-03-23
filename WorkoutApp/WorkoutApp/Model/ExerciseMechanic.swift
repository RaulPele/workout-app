//
//  ExerciseMechanic.swift
//  WorkoutApp
//
//  Created by Raul Pele on 22.03.2026.
//

import Foundation

enum ExerciseMechanic: String, Codable, Hashable {
    case compound
    case isolation

    // MARK: - Properties
    var displayName: String {
        rawValue.capitalized
    }
}
