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

    @State private var selectedTab: TabBarItem = .workouts
    @State private var workoutTemplatesNavigationManager = WorkoutTemplatesNavigationManager()
    @State private var exercisesNavigationManager = ExercisesNavigationManager()
    @State private var historyNavigationManager = WorkoutSessionsNavigationManager()

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(TabBarItem.workouts.title, systemImage: TabBarItem.workouts.systemImage, value: .workouts) {
                NavigationStack(path: $workoutTemplatesNavigationManager.path) {
                    WorkoutTemplatesListWrapper(
                        workoutTemplateRepository: dependencyContainer.workoutTemplateRepository,
                        navigationManager: workoutTemplatesNavigationManager
                    )
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            ProfileButton(authService: dependencyContainer.authService)
                        }
                    }
                }
            }

            Tab(TabBarItem.exercises.title, systemImage: TabBarItem.exercises.systemImage, value: .exercises) {
                NavigationStack(path: $exercisesNavigationManager.path) {
                    ExerciseLibraryWrapper(
                        libraryRepository: dependencyContainer.userExerciseLibraryRepository,
                        navigationManager: exercisesNavigationManager
                    )
                }
            }

            Tab(TabBarItem.history.title, systemImage: TabBarItem.history.systemImage, value: .history) {
                NavigationStack(path: $historyNavigationManager.path) {
                    HistoryWrapper(
                        workoutRepository: dependencyContainer.workoutRepository,
                        navigationManager: historyNavigationManager
                    )
                }
            }
        }
        .tint(Color.primaryColor)
    }
}

// MARK: - HistoryWrapper
private struct HistoryWrapper: View {
    @State private var viewModel: HistoryViewModel
    @Namespace private var transitionNamespace

    init(workoutRepository: any WorkoutSessionRepository, navigationManager: WorkoutSessionsNavigationManager) {
        self._viewModel = State(wrappedValue: HistoryViewModel(
            workoutRepository: workoutRepository,
            navigationManager: navigationManager
        ))
    }

    var body: some View {
        HistoryView(viewModel: viewModel, transitionNamespace: transitionNamespace)
            .navigationDestination(for: WorkoutRoute.self) { route in
                SessionDetailView(viewModel: SessionDetailViewModel(session: route.workout))
                    .navigationTransition(.zoom(sourceID: route.workout.id, in: transitionNamespace))
            }
    }
}

// MARK: - WorkoutTemplatesListWrapper
private struct WorkoutTemplatesListWrapper: View {
    let workoutTemplateRepository: any WorkoutRepository
    let navigationManager: WorkoutTemplatesNavigationManager
    @State private var viewModel: WorkoutTemplatesList.ViewModel
    @Namespace private var transitionNamespace

    init(workoutTemplateRepository: any WorkoutRepository, navigationManager: WorkoutTemplatesNavigationManager) {
        self.workoutTemplateRepository = workoutTemplateRepository
        self.navigationManager = navigationManager
        self._viewModel = State(wrappedValue: WorkoutTemplatesList.ViewModel(
            workoutTemplateRepository: workoutTemplateRepository,
            navigationManager: navigationManager
        ))
    }

    var body: some View {
        WorkoutTemplatesList.ContentView(viewModel: viewModel, transitionNamespace: transitionNamespace)
            .navigationDestination(for: WorkoutTemplateDetailRoute.self) { route in
                WorkoutTemplateDetailWrapper(
                    route: route,
                    workoutTemplateRepository: workoutTemplateRepository,
                    navigationManager: navigationManager
                )
                .navigationTransition(.zoom(sourceID: route.workoutId, in: transitionNamespace))
            }
    }
}

// MARK: - WorkoutTemplateDetailWrapper
private struct WorkoutTemplateDetailWrapper: View {
    @State private var viewModel: WorkoutTemplateDetailViewModel

    init(route: WorkoutTemplateDetailRoute, workoutTemplateRepository: any WorkoutRepository, navigationManager: WorkoutTemplatesNavigationManager) {
        self._viewModel = State(wrappedValue: WorkoutTemplateDetailViewModel(
            workoutId: route.workoutId,
            workoutRepository: workoutTemplateRepository,
            navigationManager: navigationManager
        ))
    }

    var body: some View {
        WorkoutTemplateDetailView(viewModel: viewModel)
    }
}

// MARK: - ExerciseLibraryWrapper
private struct ExerciseLibraryWrapper: View {
    @State private var viewModel: ExerciseLibraryViewModel

    init(libraryRepository: any UserExerciseLibraryRepositoryProtocol, navigationManager: ExercisesNavigationManager) {
        self._viewModel = State(initialValue: ExerciseLibraryViewModel(
            libraryRepository: libraryRepository,
            navigationManager: navigationManager
        ))
    }

    var body: some View {
        ExerciseLibraryView(viewModel: viewModel)
    }
}

// MARK: - ProfileButton
/// Account button for the Workouts toolbar. Profile isn't a tab in v1; it opens as a sheet.
private struct ProfileButton: View {
    let authService: any AuthServiceProtocol
    @State private var isPresented = false

    var body: some View {
        Button("Account", systemImage: "person.crop.circle") {
            isPresented = true
        }
        .sheet(isPresented: $isPresented) {
            ProfileSheet(authService: authService)
        }
    }
}

// MARK: - ProfileSheet
private struct ProfileSheet: View {
    let authService: any AuthServiceProtocol
    @State private var viewModel: Profile.ContentView.ViewModel
    @Environment(\.dismiss) private var dismiss

    init(authService: any AuthServiceProtocol) {
        self.authService = authService
        self._viewModel = State(wrappedValue: Profile.ContentView.ViewModel(authService: authService))
    }

    var body: some View {
        NavigationStack {
            Profile.ContentView(viewModel: viewModel)
                .navigationTitle("Account")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}

// MARK: - TabBarItem
enum TabBarItem: String, CaseIterable, Hashable {
    case workouts
    case exercises
    case history

    var title: String {
        switch self {
        case .workouts: "Workouts"
        case .exercises: "Exercises"
        case .history: "History"
        }
    }

    var systemImage: String {
        switch self {
        case .workouts: "dumbbell"
        case .exercises: "figure.strengthtraining.traditional"
        case .history: "clock.arrow.circlepath"
        }
    }
}
