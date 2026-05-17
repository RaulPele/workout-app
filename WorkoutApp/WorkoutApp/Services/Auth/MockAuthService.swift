//
//  MockAuthService.swift
//  WorkoutApp
//
//  Created by Raul Pele on 02.05.2026.
//

import AuthenticationServices
import Combine
import Foundation

// MARK: - MockAuthService
final class MockAuthService: AuthServiceProtocol {

    // MARK: - Properties
    private let authStateSubject: CurrentValueSubject<AuthState, Never>

    var authStatePublisher: AnyPublisher<AuthState, Never> {
        authStateSubject.eraseToAnyPublisher()
    }

    var currentUser: AuthUser? {
        if case .signedIn(let user) = authStateSubject.value { return user }
        return nil
    }

    // MARK: - Initializers
    init(initialState: AuthState = .signedOut) {
        self.authStateSubject = CurrentValueSubject(initialState)
    }

    // MARK: - AuthServiceProtocol
    func prepareAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {}

    func completeAppleSignIn(_ result: Result<ASAuthorization, Error>) async throws {
        let mockUser = AuthUser(uid: "mock-uid", email: "mock@example.com", displayName: "Mock User")
        authStateSubject.send(.signedIn(mockUser))
    }

    func signOut() async throws {
        authStateSubject.send(.signedOut)
    }

    func currentIDToken() async throws -> String? {
        currentUser != nil ? "mock-id-token" : nil
    }
}
