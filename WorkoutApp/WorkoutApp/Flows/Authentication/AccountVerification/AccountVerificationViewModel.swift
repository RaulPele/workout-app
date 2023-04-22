//
//  AccountVerificationViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 19.04.2023.
//

import Foundation

extension AccountVerification {
    
    class ViewModel: ObservableObject {
        
        //MARK: - Properties
        @Published var isLoading: Bool = false
        @Published var email: String = ""
        
        private let authenticationService: AuthenticationServiceProtocol
        
        var onAccountChecked: ((_ status: AccountStatus, _ email: String) -> Void)?
        
        //MARK: - initializers
        init(authenticationService: AuthenticationServiceProtocol) {
            self.authenticationService = authenticationService
        }
        
        //MARK: - Event handlers
        func handleContinueButtonTapped() {
            checkAccount()
        }
        
        private func checkAccount() {
            isLoading = true
            
            Task(priority: .userInitiated) { @MainActor in
                do {
                    let accountStatus = try await authenticationService.checkAccount(email: email)
                    onAccountChecked?(accountStatus, email)
                    
                } catch {
                    print("Error while checking account: \(error.localizedDescription)")
                }
                
                isLoading = false
            }
        }
    }
}
