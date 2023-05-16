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
    
    private let dependencyContainer: DependencyContainer
    
    init() {
        navigationController.navigationBar.isHidden = true
        
        let authService = MockedAuthenticationService()
        let workoutService = MockedWorkoutService()
        let healthKitManager = HealthKitManager()
        let workoutRepository = WorkoutAPIRepository(workoutService: workoutService, healthKitManager: healthKitManager)
//        let watchCommunicator = WatchCommunicator()
        
        dependencyContainer = DependencyContainer(
            authenticationService: authService,
            workoutService: workoutService,
            workoutRepository: workoutRepository,
            healthKitManager: healthKitManager
//            watchCommunicator: watchCommunicator
        )
    }
    
    var rootViewController: UIViewController? {
       return  navigationController
    }
    
    //MARK: - Methods
    
    func start(options connectionOptions: UIScene.ConnectionOptions?) {
//        showAuthenticationCoordinator()
        showMainCoordinator()
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
                                healthKitManager: dependencyContainer.healthKitManager)
        
        mainCoordinator?.start(options: nil)
    }
    
}
