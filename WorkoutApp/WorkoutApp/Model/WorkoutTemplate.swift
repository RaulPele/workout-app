//
//  WorkoutTemplate.swift
//  WorkoutApp
//
//  Created by Raul Pele on 21.05.2023.
//

import Foundation

struct WorkoutTemplate: Identifiable, Codable {
    
    let id: UUID
    let name: String
    let exercises: [Exercise]
}

extension WorkoutTemplate {
    
    static let mockedWorkoutTemplate = WorkoutTemplate(
        id: .init(),
        name: "My strength workout",
        exercises: [.mockedBBSquats, .mockedBBBenchPress]
    )
}
