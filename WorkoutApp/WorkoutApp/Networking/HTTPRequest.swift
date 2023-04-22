//
//  HTTPRequest.swift
//  WorkoutApp
//
//  Created by Raul Pele on 17.04.2023.
//

import Foundation

enum HTTPMethod: String {
    
    case post = "POST"
    case get = "GET"
}

protocol HTTPRequestProtocol {
    
    var method: HTTPMethod { get }
    var path: String { get }
    var headers: [String : String]? { get }
    var bodyParameters: [String: Any]? { get }
    var queryParameters: [String: Any]? { get }
    var encoding: ParameterEncoding { get }
    var isAuthorized: Bool { get }
    
}

enum ParameterEncoding {
    
    case json
    case url
    
    var headerValue: String {
        switch self {
        case .url:
            return "application/x-www-form-urlencoded; charset=utf-8"
        case .json:
            return "application/json"
        }
    }
}

struct HeaderFields {
    static let contentType = "Content-Type"
}

struct HTTPRequest: HTTPRequestProtocol {
    
    let method: HTTPMethod
    let path: String
    var headers: [String : String]? = nil
    var bodyParameters: [String : Any]? = nil
    var queryParameters: [String : Any]? = nil
    var encoding: ParameterEncoding = .json
    var isAuthorized: Bool = true
    //TODO: add keypath
}

