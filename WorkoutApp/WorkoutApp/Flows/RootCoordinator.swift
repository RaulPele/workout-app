//
//  RootCoordinator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 01.04.2023.
//

import Foundation
import UIKit
import Combine

class RootCoordinator: Coordinator {
    
    //MARK: - Properties
    
    private let navigationController: UINavigationController = .init()
    private var authenticationCoordinator: AuthenticationCoordinator?
    private var mainCoordinator: MainCoordinator?
    private var onboardingCoordinator: OnboardingCoordinator?
    private var healthKitAuthorizationCoordinator: HealthKitAuthorizationCoordinator?
    
    private let dependencyContainer: DependencyContainer
    
    init() {
        navigationController.navigationBar.isHidden = true
        
        let authService = MockedAuthenticationService()
        let workoutService = MockedWorkoutService()
        let healthKitManager = HealthKitManager()
        let workoutRepository = WorkoutAPIRepository(workoutService: workoutService, healthKitManager: healthKitManager)
        let exerciseRepository = ExerciseRepository()
        let exerciseService = ExerciseService(exerciseRepository: exerciseRepository)
        let workoutTemplateRepository = WorkoutTemplateLocalRepository()
        let watchCommunicator = WatchCommunicator()

        let workoutTemplateService = WorkoutTemplateService(repository: workoutTemplateRepository, watchCommunicator: watchCommunicator)
        
        dependencyContainer = DependencyContainer(
            authenticationService: authService,
            workoutService: workoutService,
            workoutRepository: workoutRepository,
            healthKitManager: healthKitManager,
            exerciseService: exerciseService,
            workoutTemplateService: workoutTemplateService,
            watchCommunicator: watchCommunicator
        )
    }
    
    var rootViewController: UIViewController? {
       return  navigationController
    }
    
    //MARK: - Methods
    
    func start(options connectionOptions: UIScene.ConnectionOptions?) {
        showOnboardingCoordinator()
    }
    
    private func showOnboardingCoordinator() {
        onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController, onFinishedOnboarding: { [weak self] in
            guard let self else { return }
            
            if self.dependencyContainer.healthKitManager.isAuthorizedToShare() {
                self.showMainCoordinator();
            } else {
                self.showHealthKitAuthorizationCoordinator()
            }
        })
        onboardingCoordinator?.start(options: nil)
    }
    
    private func showHealthKitAuthorizationCoordinator() {
        healthKitAuthorizationCoordinator = HealthKitAuthorizationCoordinator(
            navigationController: navigationController,
            healthKitManager: dependencyContainer.healthKitManager,
            onFinished: { [weak self] in
            self?.showMainCoordinator()
        })
        
        healthKitAuthorizationCoordinator?.start(options: nil)
    }
    
    private func showAuthenticationCoordinator() {
        authenticationCoordinator = .init(navigationController: navigationController,
                                          authenticationService: dependencyContainer.authenticationService) { [unowned self] in
            self.showMainCoordinator()
        }
        
        authenticationCoordinator?.start(options: nil)
    }
    
    private func showMainCoordinator() {
        mainCoordinator = .init(navigationController: navigationController,
                                workoutRepository: dependencyContainer.workoutRepository,
                                healthKitManager: dependencyContainer.healthKitManager,
                                exerciseService: dependencyContainer.exerciseService,
                                workoutTemplateService: dependencyContainer.workoutTemplateService)
        
        mainCoordinator?.start(options: nil)
    }
    
}
