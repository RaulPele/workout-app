//
//  AuthServiceProtocol.swift
//  WorkoutApp
//
//  Created by Raul Pele on 02.05.2026.
//

import AuthenticationServices
import Combine
import Foundation

// MARK: - Protocol
protocol AuthServiceProtocol {
    var authStatePublisher: AnyPublisher<AuthState, Never> { get }
    var currentUser: AuthUser? { get }

    /// Configure an Apple sign-in request: sets requested scopes and a fresh hashed nonce.
    /// The raw nonce is retained internally so `completeAppleSignIn` can verify the response.
    func prepareAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest)

    /// Exchange the result of a `SignInWithAppleButton` completion for a Firebase session.
    func completeAppleSignIn(_ result: Result<ASAuthorization, Error>) async throws

    func signOut() async throws

    /// Returns the current Firebase ID token, refreshing if needed. `nil` if signed out.
    func currentIDToken() async throws -> String?
}

// MARK: - AuthError
enum AuthError: Error {
    case invalidCredential
    case missingNonce
    case missingIdentityToken
}
