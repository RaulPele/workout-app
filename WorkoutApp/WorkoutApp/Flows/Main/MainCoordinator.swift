//
//  MainCoordinator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.05.2023.
//

import Foundation
import SwiftUI

struct MainCoordinatorView: View {
    
    @Environment(\.dependencyContainer) private var dependencyContainer
    
    @State private var selectedTab: TabBarItem = .workoutSessions
    @State private var workoutSessionsNavigationManager = WorkoutSessionsNavigationManager()
    @State private var workoutTemplatesNavigationManager = WorkoutTemplatesNavigationManager()
    @State private var profileNavigationManager = ProfileNavigationManager()

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: TabBarItem.workoutSessions) {
                NavigationStack(path: $workoutSessionsNavigationManager.path) {
                    HomeWrapper(
                        workoutRepository: dependencyContainer.workoutRepository,
                        healthKitManager: dependencyContainer.healthKitManager,
                        navigationManager: workoutSessionsNavigationManager
                    )
                }
            } label: {
                Label(TabBarItem.workoutSessions.title, systemImage: "dumbbell")
            }
            Tab(value: TabBarItem.workoutTemplates) {
                NavigationStack(path: $workoutTemplatesNavigationManager.path) {
                    WorkoutTemplatesListWrapper(
                        exerciseRepository: dependencyContainer.exerciseRepository,
                        exerciseDefinitionRepository: dependencyContainer.exerciseDefinitionRepository,
                        workoutTemplateRepository: dependencyContainer.workoutTemplateRepository,
                        navigationManager: workoutTemplatesNavigationManager
                    )
                }
            } label: {
                Label(TabBarItem.workoutTemplates.title, systemImage: "list.bullet.clipboard")
            }
            Tab(value: TabBarItem.profile) {
                NavigationStack(path: $profileNavigationManager.path) {
                    ProfileWrapper(authService: dependencyContainer.authService)
                }
            } label: {
                Label(TabBarItem.profile.title, systemImage: "person.crop.circle")
            }
        }
        .tint(Color.primaryColor)
    }
}

private struct HomeWrapper: View {
    let workoutRepository: any WorkoutSessionRepository
    let healthKitManager: any HealthKitManagerProtocol
    let navigationManager: WorkoutSessionsNavigationManager
    @State private var viewModel: Home.ViewModel

    init(workoutRepository: any WorkoutSessionRepository, healthKitManager: any HealthKitManagerProtocol, navigationManager: WorkoutSessionsNavigationManager) {
        self.workoutRepository = workoutRepository
        self.healthKitManager = healthKitManager
        self.navigationManager = navigationManager
        self._viewModel = State(wrappedValue: Home.ViewModel(
            workoutRepository: workoutRepository,
            healthKitManager: healthKitManager,
            navigationManager: navigationManager
        ))
    }

    var body: some View {
        Home.ContentView(viewModel: viewModel)
            .navigationDestination(for: WorkoutRoute.self) { route in
                WorkoutDetails.ContentView(viewModel: WorkoutDetails.ViewModel(session: route.workout))
            }
    }
}

private struct WorkoutTemplatesListWrapper: View {

    let exerciseRepository: any ExerciseRepositoryProtocol
    let exerciseDefinitionRepository: any ExerciseDefinitionRepositoryProtocol
    let workoutTemplateRepository: any WorkoutRepository
    let navigationManager: WorkoutTemplatesNavigationManager
    @State private var viewModel: WorkoutTemplatesList.ViewModel

    init(exerciseRepository: any ExerciseRepositoryProtocol, exerciseDefinitionRepository: any ExerciseDefinitionRepositoryProtocol, workoutTemplateRepository: any WorkoutRepository, navigationManager: WorkoutTemplatesNavigationManager) {
        self.exerciseRepository = exerciseRepository
        self.exerciseDefinitionRepository = exerciseDefinitionRepository
        self.workoutTemplateRepository = workoutTemplateRepository
        self.navigationManager = navigationManager
        self._viewModel = State(wrappedValue: WorkoutTemplatesList.ViewModel(
            workoutTemplateRepository: workoutTemplateRepository,
            navigationManager: navigationManager
        ))
    }

    var body: some View {
        WorkoutTemplatesList.ContentView(viewModel: viewModel)
            .navigationDestination(for: WorkoutTemplateBuilderRoute.self) { route in
                WorkoutTemplateBuilderWrapper(
                    exerciseRepository: exerciseRepository,
                    exerciseDefinitionRepository: exerciseDefinitionRepository,
                    workoutTemplateRepository: workoutTemplateRepository,
                    navigationManager: navigationManager,
                    route: route
                )
            }
    }
}

private struct WorkoutTemplateBuilderWrapper: View {
    let exerciseRepository: any ExerciseRepositoryProtocol
    let exerciseDefinitionRepository: any ExerciseDefinitionRepositoryProtocol
    let workoutTemplateRepository: any WorkoutRepository
    let navigationManager: WorkoutTemplatesNavigationManager
    @State private var viewModel: WorkoutTemplateBuilder.ViewModel

    init(exerciseRepository: any ExerciseRepositoryProtocol, exerciseDefinitionRepository: any ExerciseDefinitionRepositoryProtocol, workoutTemplateRepository: any WorkoutRepository, navigationManager: WorkoutTemplatesNavigationManager, route: WorkoutTemplateBuilderRoute) {
        self.exerciseRepository = exerciseRepository
        self.exerciseDefinitionRepository = exerciseDefinitionRepository
        self.workoutTemplateRepository = workoutTemplateRepository
        self.navigationManager = navigationManager
        self._viewModel = State(wrappedValue: WorkoutTemplateBuilder.ViewModel(
            exerciseRepository: exerciseRepository,
            exerciseDefinitionRepository: exerciseDefinitionRepository,
            workoutTemplateRepository: workoutTemplateRepository,
            navigationManager: navigationManager,
            workout: route.workout
        ))
    }

    var body: some View {
        WorkoutTemplateBuilder.ContentView(viewModel: viewModel)
    }
}

private struct ProfileWrapper: View {
    let authService: any AuthServiceProtocol
    @State private var viewModel: Profile.ContentView.ViewModel

    init(authService: any AuthServiceProtocol) {
        self.authService = authService
        self._viewModel = State(wrappedValue: Profile.ContentView.ViewModel(authService: authService))
    }

    var body: some View {
        Profile.ContentView(viewModel: viewModel)
    }
}

enum TabBarItem: String, CaseIterable, Hashable {
    case workoutSessions
    case workoutTemplates
    case profile

    var title: String {
        switch self {
        case .workoutSessions:
            return "Sessions"
        case .workoutTemplates:
            return "Workouts"
        case .profile:
            return "Profile"
        }
    }
}
