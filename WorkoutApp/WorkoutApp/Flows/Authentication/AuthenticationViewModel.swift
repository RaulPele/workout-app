//
//  AuthenticationViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 05.05.2026.
//

import AuthenticationServices
import Foundation

extension Authentication.ContentView {

    @Observable class ViewModel {

        // MARK: - Properties
        var isLoading = false
        var errorMessage: String?

        private let authService: any AuthServiceProtocol
        @ObservationIgnored private var signInTask: Task<Void, Never>?
        private let logger = CustomLogger(
            subsystem: Bundle.main.bundleIdentifier ?? "WorkoutApp",
            category: "AuthenticationViewModel"
        )

        // MARK: - Initializers
        init(authService: any AuthServiceProtocol) {
            self.authService = authService
        }

        // MARK: - Apple Sign In
        func handleAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
            authService.prepareAppleSignInRequest(request)
        }

        func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) {
            signInTask?.cancel()
            isLoading = true

            signInTask = Task { @MainActor [weak self] in
                guard let self else { return }
                defer { self.isLoading = false }

                do {
                    try await self.authService.completeAppleSignIn(result)
                } catch {
                    self.logger.error("Apple sign-in failed: \(error.localizedDescription)")
                    if (error as? ASAuthorizationError)?.code == .canceled { return }
                    self.errorMessage = "We couldn't sign you in. Please try again."
                }
            }
        }
    }
}
