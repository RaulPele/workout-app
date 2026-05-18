//
//  ProfileView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 17.05.2026.
//

import SwiftUI

enum Profile {

    struct ContentView: View {

        // MARK: - Properties
        let viewModel: ViewModel
        @State private var isConfirmingSignOut = false

        // MARK: - Body
        var body: some View {
            VStack(spacing: 24) {
                headerView
                Spacer()
                signOutButton
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 32)
            .padding(.top, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .alert(
                "Sign out of WorkoutApp?",
                isPresented: $isConfirmingSignOut,
//                titleVisibility: .visible
            ) {
                Button("Sign out", role: .destructive) { viewModel.signOut() }
                Button("Cancel", role: .cancel) {}
            }
            .alert(
                "Sign-Out Failed",
                isPresented: errorAlertBinding,
                actions: { Button("OK") { viewModel.errorMessage = nil } },
                message: { Text(viewModel.errorMessage ?? "") }
            )
        }

        // MARK: - Subviews
        private var headerView: some View {
            VStack(spacing: 8) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .foregroundStyle(Color.primaryColor)

                Text(displayName)
                    .font(.title2).bold()
                    .foregroundStyle(Color.onBackground)

                if let email = viewModel.currentUser?.email, email != displayName {
                    Text(email)
                        .font(.subheadline)
                        .foregroundStyle(Color.onBackground.opacity(0.7))
                }
            }
        }

        private var signOutButton: some View {
            Button {
                isConfirmingSignOut = true
            } label: {
                Text("Sign out")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .disabled(viewModel.isLoading)
            .overlay {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                }
            }
            .frame(maxWidth: 320)
        }

        // MARK: - Helpers
        private var displayName: String {
            viewModel.currentUser?.displayName
                ?? viewModel.currentUser?.email
                ?? "Signed in"
        }

        private var errorAlertBinding: Binding<Bool> {
            Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        }
    }
}

#Preview("Signed In") {
    Profile.ContentView(
        viewModel: .init(
            authService: MockAuthService(
                initialState: .signedIn(
                    AuthUser(uid: "u_1", email: "raul@example.com", displayName: "Raul Pele")
                )
            )
        )
    )
}

#Preview("Email only") {
    Profile.ContentView(
        viewModel: .init(
            authService: MockAuthService(
                initialState: .signedIn(
                    AuthUser(uid: "u_2", email: "raul@example.com", displayName: nil)
                )
            )
        )
    )
}

#Preview("Loading") {
    let viewModel = Profile.ContentView.ViewModel(
        authService: MockAuthService(
            initialState: .signedIn(
                AuthUser(uid: "u_3", email: "raul@example.com", displayName: "Raul Pele")
            )
        )
    )
    viewModel.isLoading = true
    return Profile.ContentView(viewModel: viewModel)
}

#Preview("Error") {
    let viewModel = Profile.ContentView.ViewModel(
        authService: MockAuthService(
            initialState: .signedIn(
                AuthUser(uid: "u_4", email: "raul@example.com", displayName: "Raul Pele")
            )
        )
    )
    viewModel.errorMessage = "Something went wrong. Please try again."
    return Profile.ContentView(viewModel: viewModel)
}
