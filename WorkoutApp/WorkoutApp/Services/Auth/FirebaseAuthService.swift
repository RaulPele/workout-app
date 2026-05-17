//
//  FirebaseAuthService.swift
//  WorkoutApp
//
//  Created by Raul Pele on 02.05.2026.
//

import AuthenticationServices
import Combine
import CryptoKit
import FirebaseAuth
import Foundation

// MARK: - FirebaseAuthService
final class FirebaseAuthService: AuthServiceProtocol {

    // MARK: - Properties
    private let authStateSubject = CurrentValueSubject<AuthState, Never>(.loading)
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?

    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? "WorkoutApp",
        category: "FirebaseAuthService"
    )

    var authStatePublisher: AnyPublisher<AuthState, Never> {
        authStateSubject.eraseToAnyPublisher()
    }

    var currentUser: AuthUser? {
        Auth.auth().currentUser.map(AuthUser.init(firebaseUser:))
    }

    // MARK: - Initializers
    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            if let user {
                self.authStateSubject.send(.signedIn(AuthUser(firebaseUser: user)))
            } else {
                self.authStateSubject.send(.signedOut)
            }
        }
    }

    deinit {
        if let authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
    }

    // MARK: - Sign In With Apple
    func prepareAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = Self.randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(nonce)
    }

    func completeAppleSignIn(_ result: Result<ASAuthorization, Error>) async throws {
        switch result {
        case .failure(let error):
            logger.error("Apple sign-in failed: \(error.localizedDescription)")
            throw error

        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                throw AuthError.invalidCredential
            }
            guard let rawNonce = currentNonce else {
                throw AuthError.missingNonce
            }
            guard let identityTokenData = appleIDCredential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                throw AuthError.missingIdentityToken
            }

            let credential = OAuthProvider.appleCredential(
                withIDToken: identityToken,
                rawNonce: rawNonce,
                fullName: appleIDCredential.fullName
            )

            _ = try await Auth.auth().signIn(with: credential)
            currentNonce = nil
        }
    }

    // MARK: - Session
    func signOut() async throws {
        try Auth.auth().signOut()
    }

    func currentIDToken() async throws -> String? {
        try await Auth.auth().currentUser?.getIDToken()
    }

    // MARK: - Nonce Helpers
    private static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &randomBytes)
        guard status == errSecSuccess else {
            fatalError("SecRandomCopyBytes failed with OSStatus \(status)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private static func sha256(_ input: String) -> String {
        let hash = SHA256.hash(data: Data(input.utf8))
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - AuthUser <- FirebaseAuth.User
private extension AuthUser {
    init(firebaseUser: FirebaseAuth.User) {
        self.init(
            uid: firebaseUser.uid,
            email: firebaseUser.email,
            displayName: firebaseUser.displayName
        )
    }
}
