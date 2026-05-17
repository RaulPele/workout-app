//
//  AuthState.swift
//  WorkoutApp
//
//  Created by Raul Pele on 02.05.2026.
//

import Foundation

// MARK: - AuthState
enum AuthState: Equatable {
    case loading
    case signedOut
    case signedIn(AuthUser)
}

// MARK: - AuthUser
/// Lightweight user identity carried alongside the auth state.
/// `uid` is the Firebase UID and is the stable user key for every persisted resource.
struct AuthUser: Equatable {
    let uid: String
    let email: String?
    let displayName: String?
}
