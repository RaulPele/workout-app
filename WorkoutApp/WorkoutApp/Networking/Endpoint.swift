//
//  Endpoint.swift
//  WorkoutApp
//
//  Created by Raul Pele on 22.03.2026.
//

import Foundation

struct Endpoint {

    // MARK: - Properties
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    let body: Data?

    // MARK: - Initializers
    init(path: String, method: HTTPMethod = .get, queryItems: [URLQueryItem] = [], body: Data? = nil) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.body = body
    }
}

// MARK: - HTTPMethod
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Exercise Definition Endpoints
extension Endpoint {
    static func exercises(
        muscle: MuscleGroup? = nil,
        equipment: Equipment? = nil,
        category: ExerciseCategory? = nil,
        page: Int = 0,
        size: Int = 20
    ) -> Endpoint {
        var queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size)),
        ]

        if let muscle {
            queryItems.append(URLQueryItem(name: "muscle", value: muscle.rawValue))
        }
        if let equipment {
            queryItems.append(URLQueryItem(name: "equipment", value: equipment.rawValue))
        }
        if let category {
            queryItems.append(URLQueryItem(name: "category", value: category.rawValue))
        }

        return Endpoint(path: "/api/exercises", queryItems: queryItems)
    }

    static func exercise(id: String) -> Endpoint {
        Endpoint(path: "/api/exercises/\(id)")
    }

    static func searchExercises(query: String, page: Int = 0, size: Int = 20) -> Endpoint {
        Endpoint(
            path: "/api/exercises/search",
            queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "size", value: String(size)),
            ]
        )
    }

    static func muscles() -> Endpoint {
        Endpoint(path: "/api/exercises/muscles")
    }

    static func equipment() -> Endpoint {
        Endpoint(path: "/api/exercises/equipment")
    }

    static func createExercise(_ definition: ExerciseDefinition) -> Endpoint {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let body = try? encoder.encode(definition)
        return Endpoint(path: "/api/exercises", method: .post, body: body)
    }
}
