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
    
    private let dependencyContainer: DependencyContainer = MockedDependencyContainer()
    
    init() {
        navigationController.navigationBar.isHidden = true
    }
    
    var rootViewController: UIViewController? {
       return  navigationController
    }
    
    //MARK: - Methods
    
    func start(options connectionOptions: UIScene.ConnectionOptions?) {
        showAuthenticationCoordinator()
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
                                workoutRepository: dependencyContainer.workoutRepository)
        
        mainCoordinator?.start(options: nil)
    }
    
}
