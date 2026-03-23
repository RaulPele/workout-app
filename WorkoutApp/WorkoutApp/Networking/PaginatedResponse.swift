//
//  PaginatedResponse.swift
//  WorkoutApp
//
//  Created by Raul Pele on 22.03.2026.
//

import Foundation

struct PaginatedResponse<T: Decodable>: Decodable {
    let content: [T]
    let totalPages: Int
    let totalElements: Int
    let number: Int
    let last: Bool
}
