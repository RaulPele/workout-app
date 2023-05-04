//
//  AuthenticationService.swift
//  WorkoutApp
//
//  Created by Raul Pele on 14.04.2023.
//

import Foundation

protocol AuthenticationServiceProtocol {
    
    func checkAccount(email: String) async throws -> AccountStatus
    func login(email: String, password: String) async throws
}

class AuthenticationService: AuthenticationServiceProtocol {
    
    let httpClient: HTTPClient = .init()
    
    func checkAccount(email: String) async throws -> AccountStatus {
        return .active
    }
    
    func login(email: String, password: String) async throws {
        
    }
}


