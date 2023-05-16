//
//  Message.swift
//  WorkoutApp
//
//  Created by Raul Pele on 24.05.2023.
//

import Foundation

struct Message: Codable {
    
    let contentType: ContentType
    let data: Data
    
    enum ContentType: Codable {
        case workoutTemplates
        case workoutSession
    }
}
