//
//  Equipment.swift
//  WorkoutApp
//
//  Created by Raul Pele on 22.03.2026.
//

import Foundation

enum Equipment: String, Codable, CaseIterable, Hashable {
    case barbell
    case dumbbell
    case cable
    case machine
    case kettlebells
    case bands
    case bodyOnly = "body only"
    case medicineBall = "medicine ball"
    case exerciseBall = "exercise ball"
    case ezCurlBar = "e-z curl bar"
    case foamRoll = "foam roll"
    case other

    // MARK: - Properties
    var displayName: String {
        switch self {
        case .bodyOnly: "Body Only"
        case .medicineBall: "Medicine Ball"
        case .exerciseBall: "Exercise Ball"
        case .ezCurlBar: "E-Z Curl Bar"
        case .foamRoll: "Foam Roll"
        default: rawValue.capitalized
        }
    }
}
