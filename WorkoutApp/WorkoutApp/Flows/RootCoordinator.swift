//
//  RootCoordinator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 01.04.2023.
//

import Foundation
import SwiftUI

enum RootFlow {
    case loading
    case authentication
    case healthKitAuthorization
    case main
}

struct RootCoordinatorView: View {

    @Environment(\.dependencyContainer) private var dependencyContainer

    @State private var currentFlow: RootFlow = .loading

    var body: some View {
        Group {
            switch currentFlow {
            case .loading:
                LoadingView()
            case .authentication:
                AuthenticationWrapper(authService: dependencyContainer.authService)
            case .healthKitAuthorization:
                HealthKitAuthorizationWrapper(
                    healthKitManager: dependencyContainer.healthKitManager,
                    onFinished: {
                        currentFlow = .main
                    }
                )
            case .main:
                MainCoordinatorView()
            }
        }
        .onReceive(dependencyContainer.authService.authStatePublisher) { state in
            handleAuthState(state)
        }
    }

    private func handleAuthState(_ state: AuthState) {
        switch state {
        case .loading:
            currentFlow = .loading
        case .signedOut:
            currentFlow = .authentication
        case .signedIn:
            currentFlow = dependencyContainer.healthKitManager.isAuthorizedToShare()
                ? .main
                : .healthKitAuthorization
        }
    }
}

// MARK: - LoadingView
private struct LoadingView: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
    }
}

// MARK: - AuthenticationWrapper
private struct AuthenticationWrapper: View {
    @State private var viewModel: Authentication.ContentView.ViewModel

    init(authService: any AuthServiceProtocol) {
        self._viewModel = State(initialValue: Authentication.ContentView.ViewModel(authService: authService))
    }

    var body: some View {
        Authentication.ContentView(viewModel: viewModel)
    }
}

// MARK: - HealthKitAuthorizationWrapper
private struct HealthKitAuthorizationWrapper: View {
    let healthKitManager: any HealthKitManagerProtocol
    let onFinished: () -> Void
    @State private var viewModel: HealthKitAuthorization.ContentView.ViewModel

    init(healthKitManager: any HealthKitManagerProtocol, onFinished: @escaping () -> Void) {
        self.healthKitManager = healthKitManager
        self.onFinished = onFinished
        self._viewModel = State(initialValue: HealthKitAuthorization.ContentView.ViewModel(healthKitManager: healthKitManager))
    }

    var body: some View {
        HealthKitAuthorization.ContentView(viewModel: viewModel)
            .onAppear {
                viewModel.onFinished = onFinished
            }
    }
}
