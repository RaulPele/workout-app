//
//  AuthenticationService.swift
//  WorkoutApp
//
//  Created by Raul Pele on 14.04.2023.
//

import Foundation

protocol AuthenticationServiceProtocol {
    
    func checkAccount(email: String) async throws -> AccountStatus
}

class AuthenticationService: AuthenticationServiceProtocol {
    
    let httpClient: HTTPClient = .init()
    
    func checkAccount(email: String) async throws -> AccountStatus {
        return .active
    }
}


