//
//  HTTPClient.swift
//  WorkoutApp
//
//  Created by Raul Pele on 17.04.2023.
//

import Foundation

protocol HTTPClientProtocol {
    func sendRequest<T: Decodable>(_ request: HTTPRequest) async throws -> T
    func sendRequest(_ request: HTTPRequest) async throws
}

class HTTPClient: HTTPClientProtocol {
    
    let configuration: HTTPClientConfiguration
    private(set) var session: URLSession

    init(configuration: HTTPClientConfiguration) {
        self.configuration = configuration
        self.session = URLSession.shared
    }
    
    init() {
        self.configuration = DefaultClientConfiguration(serverURL: .init(string: "")!)
        self.session = URLSession.shared
    }
    
    func sendRequest<T: Decodable>(_ request: HTTPRequest) async throws -> T {
        let urlRequest = try makeURLRequest(from: request)
        return try await decodeResponse(urlRequest, for: request)
        
    }
    
    func sendRequest(_ request: HTTPRequest) async throws {
        
    }
    
    private func decodeResponse<T: Decodable>(
        _ request: URLRequest, for httpRequest: HTTPRequest
    ) async throws -> T {
        
        try Task.checkCancellation()
        let (data, response): (Data, URLResponse) = try await session.data(for: request)
        print("RESPONSE: \(String(data: data, encoding: .utf8))")
        // TODO: error handling
        let decoder = JSONDecoder()
        let objects: [T] = try decoder.decode([T].self, from: data) //keypath?
        
        return objects[0]
        
    }

    private func makeURLRequest(from httpRequest: HTTPRequest) throws -> URLRequest {
        var url = configuration.serverURL.appendingPathComponent(httpRequest.path, conformingTo: .text)

        // add query items
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = httpRequest.queryParameters {
            urlComponents.queryItems = queryItems.map { URLQueryItem(name: $0, value: "\($1)") }
            url = urlComponents.url ?? url
        }
        
        // create the request
        var request = URLRequest(url: url)
        request.httpMethod = httpRequest.method.rawValue
        
        // add headers
        // TODO: add any general headers directly to the configuration
        // TODO: handle authorization
        httpRequest.headers?.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // body parameters
        if let bodyParameters = httpRequest.bodyParameters,
           httpRequest.method != .get {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters)
        }
        
        if httpRequest.bodyParameters?.isEmpty == false {
            request.setValue(httpRequest.encoding.headerValue, forHTTPHeaderField: HeaderFields.contentType)
        }
        
        request.timeoutInterval = configuration.timeoutInterval
        
        return request
    }
}
