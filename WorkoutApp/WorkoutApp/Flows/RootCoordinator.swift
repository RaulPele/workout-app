//
//  RootCoordinator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 01.04.2023.
//

import Foundation
import SwiftUI

enum RootFlow {
    case onboarding
    case healthKitAuthorization
    case authentication
    case main
}

struct RootCoordinatorView: View {
    
    @State private var currentFlow: RootFlow = .main
    @State private var dependencyContainer: DependencyContainer = {
        let healthKitManager = HealthKitManager()
        let workoutRepository = WorkoutSessionAPIRepository(healthKitManager: healthKitManager)
        let exerciseRepository = ExerciseRepository()
        let workoutTemplateRepository = WorkoutLocalRepository()
        let watchCommunicator = WatchCommunicator(workoutRepository: workoutTemplateRepository)

        return DependencyContainer(
            workoutRepository: workoutRepository,
            workoutTemplateRepository: workoutTemplateRepository,
            exerciseRepository: exerciseRepository,
            healthKitManager: healthKitManager,
            watchCommunicator: watchCommunicator
        )
    }()
    
    var body: some View {
        Group {
            switch currentFlow {
            case .onboarding:
                OnboardingView(
                    onFinishedOnboarding: {
                        determineNextFlow()
                    }
                )
            case .healthKitAuthorization:
                HealthKitAuthorizationWrapper(
                    healthKitManager: dependencyContainer.healthKitManager,
                    onFinished: {
                        currentFlow = .main
                    }
                )
            case .authentication:
                EmptyView()
            case .main:
                MainCoordinatorView(
                    dependencyContainer: dependencyContainer
                )
            }
        }
        .onAppear {
            determineNextFlow()
        }
    }
    
    private func determineNextFlow() {
        if dependencyContainer.healthKitManager.isAuthorizedToShare() {
            currentFlow = .main
        } else {
            currentFlow = .healthKitAuthorization
        }
    }
}

private struct HealthKitAuthorizationWrapper: View {
    let healthKitManager: HealthKitManager
    let onFinished: () -> Void
    @State private var viewModel: HealthKitAuthorization.ContentView.ViewModel
    
    init(healthKitManager: HealthKitManager, onFinished: @escaping () -> Void) {
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
