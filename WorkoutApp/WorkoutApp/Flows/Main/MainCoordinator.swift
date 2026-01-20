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
                        exerciseService: dependencyContainer.exerciseService,
                        workoutTemplateService: dependencyContainer.workoutTemplateService,
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
    let workoutRepository: any WorkoutRepository
    let healthKitManager: HealthKitManager
    let navigationManager: WorkoutSessionsNavigationManager
    @StateObject private var viewModel: Home.ViewModel
    
    init(workoutRepository: any WorkoutRepository, healthKitManager: HealthKitManager, navigationManager: WorkoutSessionsNavigationManager) {
        self.workoutRepository = workoutRepository
        self.healthKitManager = healthKitManager
        self.navigationManager = navigationManager
        self._viewModel = StateObject(wrappedValue: Home.ViewModel(workoutRepository: workoutRepository, healthKitManager: healthKitManager))
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
    
    let exerciseService: any ExerciseServiceProtocol
    let workoutTemplateService: any WorkoutTemplateServiceProtocol
    let navigationManager: WorkoutTemplatesNavigationManager
    @State private var viewModel: WorkoutTemplatesList.ViewModel
    
    init(exerciseService: any ExerciseServiceProtocol, workoutTemplateService: any WorkoutTemplateServiceProtocol, navigationManager: WorkoutTemplatesNavigationManager) {
        self.exerciseService = exerciseService
        self.workoutTemplateService = workoutTemplateService
        self.navigationManager = navigationManager
        self._viewModel = State(wrappedValue: WorkoutTemplatesList.ViewModel(workoutTemplateService: workoutTemplateService))
    }
    
    var body: some View {
        WorkoutTemplatesList.ContentView(viewModel: viewModel)
            .navigationDestination(for: WorkoutTemplateBuilderRoute.self) { route in
                WorkoutTemplateBuilderWrapper(
                    exerciseService: exerciseService,
                    workoutTemplateService: workoutTemplateService,
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
    let exerciseService: any ExerciseServiceProtocol
    let workoutTemplateService: any WorkoutTemplateServiceProtocol
    let navigationManager: WorkoutTemplatesNavigationManager
    @State private var viewModel: WorkoutTemplateBuilder.ViewModel
    
    init(exerciseService: any ExerciseServiceProtocol, workoutTemplateService: any WorkoutTemplateServiceProtocol, navigationManager: WorkoutTemplatesNavigationManager, route: WorkoutTemplateBuilderRoute) {
        self.exerciseService = exerciseService
        self.workoutTemplateService = workoutTemplateService
        self.navigationManager = navigationManager
        self._viewModel = State(wrappedValue: WorkoutTemplateBuilder.ViewModel(
            exerciseService: exerciseService,
            workoutTemplateService: workoutTemplateService,
            templateId: route.templateId
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
