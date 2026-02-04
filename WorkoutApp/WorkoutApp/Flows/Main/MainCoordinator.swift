//
//  MainCoordinator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.05.2023.
//

import Foundation
import SwiftUI

struct MainCoordinatorView: View {
    
    let dependencyContainer: DependencyContainer
    
    @State private var selectedTab: TabBarItem = .workoutSessions
    @State private var workoutSessionsNavigationManager = WorkoutSessionsNavigationManager()
    @State private var workoutTemplatesNavigationManager = WorkoutTemplatesNavigationManager()
    
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
                        workoutTemplateRepository: dependencyContainer.workoutTemplateRepository,
                        navigationManager: workoutTemplatesNavigationManager
                    )
                }
            } label: {
                Label(TabBarItem.workoutTemplates.title, systemImage: "list.bullet.clipboard")
            }
        }
        .tint(Color.primaryColor)
    }
}

private struct HomeWrapper: View {
    let workoutRepository: any WorkoutSessionRepository
    let healthKitManager: HealthKitManager
    let navigationManager: WorkoutSessionsNavigationManager
    @State private var viewModel: Home.ViewModel

    init(workoutRepository: any WorkoutSessionRepository, healthKitManager: HealthKitManager, navigationManager: WorkoutSessionsNavigationManager) {
        self.workoutRepository = workoutRepository
        self.healthKitManager = healthKitManager
        self.navigationManager = navigationManager
        self._viewModel = State(wrappedValue: Home.ViewModel(workoutRepository: workoutRepository, healthKitManager: healthKitManager))
    }
    
    var body: some View {
        Home.ContentView(viewModel: viewModel)
            .navigationDestination(for: WorkoutRoute.self) { route in
                WorkoutDetails.ContentView(viewModel: WorkoutDetails.ViewModel(workout: route.workout))
            }
            .onAppear {
                viewModel.navigationManager = navigationManager
            }
    }
}

private struct WorkoutTemplatesListWrapper: View {

    let exerciseRepository: any ExerciseRepositoryProtocol
    let workoutTemplateRepository: any WorkoutRepository
    let navigationManager: WorkoutTemplatesNavigationManager
    @State private var viewModel: WorkoutTemplatesList.ViewModel

    init(exerciseRepository: any ExerciseRepositoryProtocol, workoutTemplateRepository: any WorkoutRepository, navigationManager: WorkoutTemplatesNavigationManager) {
        self.exerciseRepository = exerciseRepository
        self.workoutTemplateRepository = workoutTemplateRepository
        self.navigationManager = navigationManager
        self._viewModel = State(wrappedValue: WorkoutTemplatesList.ViewModel(workoutTemplateRepository: workoutTemplateRepository))
    }

    var body: some View {
        WorkoutTemplatesList.ContentView(viewModel: viewModel)
            .navigationDestination(for: WorkoutTemplateBuilderRoute.self) { route in
                WorkoutTemplateBuilderWrapper(
                    exerciseRepository: exerciseRepository,
                    workoutTemplateRepository: workoutTemplateRepository,
                    navigationManager: navigationManager,
                    route: route
                )
            }
            .onAppear {
                viewModel.navigationManager = navigationManager //TODO: refactor this; could be sent through environment
            }
    }
}

private struct WorkoutTemplateBuilderWrapper: View {
    let exerciseRepository: any ExerciseRepositoryProtocol
    let workoutTemplateRepository: any WorkoutRepository
    let navigationManager: WorkoutTemplatesNavigationManager
    @State private var viewModel: WorkoutTemplateBuilder.ViewModel

    init(exerciseRepository: any ExerciseRepositoryProtocol, workoutTemplateRepository: any WorkoutRepository, navigationManager: WorkoutTemplatesNavigationManager, route: WorkoutTemplateBuilderRoute) {
        self.exerciseRepository = exerciseRepository
        self.workoutTemplateRepository = workoutTemplateRepository
        self.navigationManager = navigationManager
        self._viewModel = State(wrappedValue: WorkoutTemplateBuilder.ViewModel(
            exerciseRepository: exerciseRepository,
            workoutTemplateRepository: workoutTemplateRepository,
            workout: route.workout
        ))
    }
    
    var body: some View {
        WorkoutTemplateBuilder.ContentView(viewModel: viewModel)
            .onAppear {
                viewModel.navigationManager = navigationManager
            }
    }
}

enum TabBarItem: String, CaseIterable, Hashable {
    case workoutSessions
    case workoutTemplates
    
    var title: String {
        switch self {
        case .workoutSessions:
            return "Sessions"
        case .workoutTemplates:
            return "Workouts"
        }
    }
}
