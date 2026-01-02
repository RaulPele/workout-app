//
//  AuthenticationCoordinator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 08.04.2023.
//

import Foundation
import SwiftUI

enum AuthenticationFlow {
    case accountVerification
    case login(email: String)
    case register
}

struct AuthenticationCoordinatorView: View {
    
    let dependencyContainer: DependencyContainer
    let onAuthenticationCompleted: () -> Void
    
    @State private var navigationManager = AuthenticationNavigationManager()
    @State private var currentFlow: AuthenticationFlow = .accountVerification
    @State private var loginEmail: String = ""
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            Group {
                switch currentFlow {
                case .accountVerification:
                    AccountVerificationWrapper(
                        authenticationService: dependencyContainer.authenticationService,
                        onAccountChecked: { status, email in
                            handleAccountChecked(status: status, email: email)
                        }
                    )
                case .login(let email):
                    LoginWrapper(
                        authenticationService: dependencyContainer.authenticationService,
                        email: email,
                        onLoginCompleted: {
                            onAuthenticationCompleted()
                        }
                    )
                case .register:
                    // TODO: Implement register screen
                    Text("Register screen - TODO")
                }
            }
        }
    }
    
    private func handleAccountChecked(status: AccountStatus, email: String) {
        switch status {
        case .inactive:
            // TODO: redirect to register flow
            currentFlow = .register
        case .active:
            loginEmail = email
            currentFlow = .login(email: email)
        }
    }
}

private struct AccountVerificationWrapper: View {
    let authenticationService: AuthenticationServiceProtocol
    let onAccountChecked: (AccountStatus, String) -> Void
    @StateObject private var viewModel: AccountVerification.ViewModel
    
    init(authenticationService: AuthenticationServiceProtocol, onAccountChecked: @escaping (AccountStatus, String) -> Void) {
        self.authenticationService = authenticationService
        self.onAccountChecked = onAccountChecked
        self._viewModel = StateObject(wrappedValue: AccountVerification.ViewModel(authenticationService: authenticationService))
    }
    
    var body: some View {
        AccountVerification.ContentView(viewModel: viewModel)
            .onAppear {
                viewModel.onAccountChecked = onAccountChecked
            }
    }
}

private struct LoginWrapper: View {
    let authenticationService: AuthenticationServiceProtocol
    let email: String
    let onLoginCompleted: () -> Void
    @StateObject private var viewModel: Login.ViewModel
    
    init(authenticationService: AuthenticationServiceProtocol, email: String, onLoginCompleted: @escaping () -> Void) {
        self.authenticationService = authenticationService
        self.email = email
        self.onLoginCompleted = onLoginCompleted
        self._viewModel = StateObject(wrappedValue: Login.ViewModel(authenticationService: authenticationService))
    }
    
    var body: some View {
        Login.ContentView(viewModel: viewModel)
            .onAppear {
                viewModel.email = email
                viewModel.onLoginCompleted = onLoginCompleted
            }
    }
}

// Legacy Coordinator class kept for reference but not used
class AuthenticationCoordinator: Coordinator {
    
    var rootViewController: UIViewController? {
        return nil
    }
    
    func start(options connectionOptions: UIScene.ConnectionOptions?) {
        // No longer used - replaced by AuthenticationCoordinatorView
    }
}
