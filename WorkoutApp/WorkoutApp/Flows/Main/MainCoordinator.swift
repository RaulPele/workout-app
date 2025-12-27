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
    @StateObject private var workoutSessionsNavigationManager = WorkoutSessionsNavigationManager()
    @StateObject private var workoutTemplatesNavigationManager = WorkoutTemplatesNavigationManager()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Workout Sessions Tab
            NavigationStack(path: $workoutSessionsNavigationManager.path) {
                HomeWrapper(
                    workoutRepository: dependencyContainer.workoutRepository,
                    healthKitManager: dependencyContainer.healthKitManager,
                    navigationManager: workoutSessionsNavigationManager
                )
            }
            .tag(TabBarItem.workoutSessions)
            .tabItem {
                Label(TabBarItem.workoutSessions.title, systemImage: "dumbbell")
            }
            
            // Workout Templates Tab
            NavigationStack(path: $workoutTemplatesNavigationManager.path) {
                WorkoutTemplatesListWrapper(
                    exerciseService: dependencyContainer.exerciseService,
                    workoutTemplateService: dependencyContainer.workoutTemplateService,
                    navigationManager: workoutTemplatesNavigationManager
                )
            }
            .tag(TabBarItem.workoutTemplates)
            .tabItem {
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
    @StateObject private var viewModel: WorkoutTemplatesList.ViewModel
    
    init(exerciseService: any ExerciseServiceProtocol, workoutTemplateService: any WorkoutTemplateServiceProtocol, navigationManager: WorkoutTemplatesNavigationManager) {
        self.exerciseService = exerciseService
        self.workoutTemplateService = workoutTemplateService
        self.navigationManager = navigationManager
        self._viewModel = StateObject(wrappedValue: WorkoutTemplatesList.ViewModel(workoutTemplateService: workoutTemplateService))
    }
    
    var body: some View {
        WorkoutTemplatesList.ContentView(viewModel: viewModel)
            .navigationDestination(for: WorkoutTemplateBuilderRoute.self) { _ in
                WorkoutTemplateBuilderWrapper(
                    exerciseService: exerciseService,
                    workoutTemplateService: workoutTemplateService,
                    navigationManager: navigationManager
                )
            }
            .onAppear {
                viewModel.navigationManager = navigationManager
            }
    }
}

private struct WorkoutTemplateBuilderWrapper: View {
    let exerciseService: any ExerciseServiceProtocol
    let workoutTemplateService: any WorkoutTemplateServiceProtocol
    let navigationManager: WorkoutTemplatesNavigationManager
    @StateObject private var viewModel: WorkoutTemplateBuilder.ViewModel
    
    init(exerciseService: any ExerciseServiceProtocol, workoutTemplateService: any WorkoutTemplateServiceProtocol, navigationManager: WorkoutTemplatesNavigationManager) {
        self.exerciseService = exerciseService
        self.workoutTemplateService = workoutTemplateService
        self.navigationManager = navigationManager
        self._viewModel = StateObject(wrappedValue: WorkoutTemplateBuilder.ViewModel(exerciseService: exerciseService, workoutTemplateService: workoutTemplateService))
    }
    
    var body: some View {
        WorkoutTemplateBuilder.ContentView(viewModel: viewModel)
            .onAppear {
                viewModel.navigationManager = navigationManager
            }
    }
}

enum TabBarItem: String, CaseIterable {
    case workoutSessions
    case workoutTemplates
    
    var title: String {
        switch self {
        case .workoutSessions:
            return "Sessions"
        case .workoutTemplates:
            return "Templates"
        }
    }
}

// Legacy Coordinator class kept for reference but not used
class MainCoordinator: Coordinator {
    
    var rootViewController: UIViewController? {
        return nil
    }
    
    func start(options connectionOptions: UIScene.ConnectionOptions?) {
        // No longer used - replaced by MainCoordinatorView
    }
}
