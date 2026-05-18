//
//  ProfileViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 17.05.2026.
//

import Foundation

extension Profile.ContentView {

    @Observable class ViewModel {

        // MARK: - Properties
        var isLoading = false
        var errorMessage: String?

        var currentUser: AuthUser? { authService.currentUser }

        private let authService: any AuthServiceProtocol
        @ObservationIgnored private var signOutTask: Task<Void, Never>?
        private let logger = CustomLogger(
            subsystem: Bundle.main.bundleIdentifier ?? "WorkoutApp",
            category: "ProfileViewModel"
        )

        // MARK: - Initializers
        init(authService: any AuthServiceProtocol) {
            self.authService = authService
        }

        // MARK: - Sign Out
        func signOut() {
            signOutTask?.cancel()
            isLoading = true

            signOutTask = Task { @MainActor [weak self] in
                guard let self else { return }
                defer { self.isLoading = false }

                do {
                    try await self.authService.signOut()
                } catch {
                    self.logger.error("Sign-out failed: \(error.localizedDescription)")
                    self.errorMessage = "We couldn't sign you out. Please try again."
                }
            }
        }
    }
}
