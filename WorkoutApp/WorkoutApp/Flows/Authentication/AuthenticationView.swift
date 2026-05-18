//
//  AuthenticationView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 05.05.2026.
//

import AuthenticationServices
import SwiftUI

enum Authentication {

    struct ContentView: View {

        // MARK: - Properties
        let viewModel: ViewModel
        @Environment(\.colorScheme) private var colorScheme

        // MARK: - Body
        var body: some View {
            VStack(spacing: 24) {
                Spacer()
                headerView
                Spacer()
                signInButton
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .alert(
                "Sign-In Failed",
                isPresented: errorAlertBinding,
                actions: { Button("OK") { viewModel.errorMessage = nil } },
                message: { Text(viewModel.errorMessage ?? "") }
            )
        }

        // MARK: - Subviews
        private var headerView: some View {
            VStack(spacing: 12) {
                Text("WorkoutApp")
                    .font(.largeTitle).bold()
                    .foregroundStyle(Color.onBackground)
                Text("Sign in to continue")
                    .font(.body)
                    .foregroundStyle(Color.onBackground.opacity(0.7))
            }
        }

        private var signInButton: some View {
            SignInWithAppleButton(
                .signIn,
                onRequest: viewModel.handleAppleRequest,
                onCompletion: viewModel.handleAppleCompletion
            )
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 50)
            .frame(maxWidth: 320)
            .disabled(viewModel.isLoading)
            .overlay {
                if viewModel.isLoading {
                    ProgressView().tint(colorScheme == .dark ? .black : .white)
                }
            }
        }

        // MARK: - Helpers
        private var errorAlertBinding: Binding<Bool> {
            Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        }
    }
}

#Preview("Idle") {
    Authentication.ContentView(viewModel: .init(authService: MockAuthService()))
}

#Preview("Loading") {
    let viewModel = Authentication.ContentView.ViewModel(authService: MockAuthService())
    viewModel.isLoading = true
    return Authentication.ContentView(viewModel: viewModel)
}

#Preview("Error") {
    let viewModel = Authentication.ContentView.ViewModel(authService: MockAuthService())
    viewModel.errorMessage = "We couldn't sign you in. Please try again."
    return Authentication.ContentView(viewModel: viewModel)
}
