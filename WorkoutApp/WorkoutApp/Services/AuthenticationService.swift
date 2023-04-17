//
//  AuthenticationService.swift
//  WorkoutApp
//
//  Created by Raul Pele on 14.04.2023.
//

import Foundation

struct Responses {
    
    struct CheckEmail {
        
    }
}

protocol AuthenticationService {
    
    func checkEmail(email: String) throws -> Responses.CheckEmail
}


class MockedAuthenticationService: AuthenticationService {
    func checkEmail(email: String) throws -> Responses.CheckEmail {
        
    }
}
