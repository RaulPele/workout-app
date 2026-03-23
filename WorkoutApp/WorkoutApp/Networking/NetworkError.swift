//
//  NetworkError.swift
//  WorkoutApp
//
//  Created by Raul Pele on 22.03.2026.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case httpError(statusCode: Int)
    case decodingError(Error)
    case noData
    case unauthorized
}

// MARK: - LocalizedError
extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The URL is invalid."
        case .httpError(let statusCode):
            "HTTP error with status code \(statusCode)."
        case .decodingError(let error):
            "Failed to decode response: \(error.localizedDescription)"
        case .noData:
            "No data received from the server."
        case .unauthorized:
            "Unauthorized. Please sign in again."
        }
    }
}
