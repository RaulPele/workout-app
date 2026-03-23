//
//  APIClient.swift
//  WorkoutApp
//
//  Created by Raul Pele on 22.03.2026.
//

import Foundation

// MARK: - APIClientProtocol
protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

// MARK: - APIClient
struct APIClient: APIClientProtocol {

    // MARK: - Properties
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? "WorkoutApp",
        category: "APIClient"
    )

    // MARK: - Initializers
    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    // MARK: - Public Methods
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let urlRequest = try buildRequest(for: endpoint)
        logger.debug("Request: \(endpoint.method.rawValue) \(urlRequest.url?.absoluteString ?? "")")

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        logger.debug("Response: \(httpResponse.statusCode) for \(endpoint.path)")

        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                logger.error("Decoding error for \(endpoint.path): \(error.localizedDescription)")
                throw NetworkError.decodingError(error)
            }
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
    }

    // MARK: - Private Methods
    private func buildRequest(for endpoint: Endpoint) throws -> URLRequest {
        var components = URLComponents(url: baseURL.appending(path: endpoint.path), resolvingAgainstBaseURL: true)

        if !endpoint.queryItems.isEmpty {
            components?.queryItems = endpoint.queryItems
        }

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = endpoint.body

        return request
    }
}

// MARK: - MockedAPIClient
struct MockedAPIClient: APIClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        throw NetworkError.noData
    }
}
