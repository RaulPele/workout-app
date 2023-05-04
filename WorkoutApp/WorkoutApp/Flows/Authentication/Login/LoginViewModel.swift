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
        
        var onLoginCompleted: (() -> Void)? = nil
        
        var loginTask: Task<Void, Never>?
        
        init(authenticationService: AuthenticationServiceProtocol) {
            self.authenticationService = authenticationService
        }
        
        deinit {
            loginTask?.cancel()
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
            loginTask?.cancel()
            
            loginTask = Task(priority: .userInitiated) { @MainActor in
                do {
                    try await authenticationService.login(email: email, password: password) //TODO: catch response
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                        self?.onLoginCompleted?()
                    }
                } catch {
                    print("Error while logging in \(error.localizedDescription)")
                }
            }
        }
    }
}
