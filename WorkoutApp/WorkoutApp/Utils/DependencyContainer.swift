//
//  DependencyContainer.swift
//  WorkoutApp
//
//  Created by Raul Pele on 19.04.2023.
//

import Foundation

class DependencyContainer {
    let authenticationService: AuthenticationServiceProtocol
    
    init(authenticationService: AuthenticationServiceProtocol) {
        self.authenticationService = authenticationService
    }
}

class MockedDependencyContainer: DependencyContainer {
    init() {
        super.init(authenticationService: MockedAuthenticationService())
    }
}
