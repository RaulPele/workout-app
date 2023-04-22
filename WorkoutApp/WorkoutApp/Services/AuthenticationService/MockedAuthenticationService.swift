//
//  MockedAuthenticationService.swift
//  WorkoutApp
//
//  Created by Raul Pele on 19.04.2023.
//

import Foundation

class MockedAuthenticationService: AuthenticationServiceProtocol {
    
    func checkAccount(email: String) async throws -> AccountStatus {
        return .active
    }
}
