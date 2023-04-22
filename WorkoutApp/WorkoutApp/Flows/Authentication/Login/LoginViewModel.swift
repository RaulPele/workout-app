//
// LoginViewModel.swift
// WorkoutApp
//
// Created by Raul Pele on 08.04.2023.
//
//

import Foundation

struct CatResponse: Decodable {
    let text: String
}

extension Login {
    
    class ViewModel: ObservableObject {
        
        @Published var isLoading: Bool = false
        @Published var email: String = ""
        @Published var password: String = ""
        
        private let authenticationService: AuthenticationServiceProtocol
        
        init(authenticationService: AuthenticationServiceProtocol) {
            self.authenticationService = authenticationService
        }
        
        func testAPI() {
            let url = URL(string: "https://cat-fact.herokuapp.com")!
            
            let configuration = DefaultClientConfiguration(serverURL: url)
            let client = HTTPClient(configuration: configuration)
            let task = Task(priority: .background) {
                let response: CatResponse = try await client.sendRequest(
                    .init(method: .get,
                          path: "facts")
                )
                print(response.text)
                
            }
        }
        
        //MARK: - Event handlers
        func handleContinueButtonTapped() {
//            checkAccount()
            //TODO: login
        }
    }
}
