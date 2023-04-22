//
//  RootCoordinator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 01.04.2023.
//

import Foundation
import UIKit

class RootCoordinator: Coordinator {
    
    //MARK: - Properties
    
    private let navigationController: UINavigationController = .init()
    private var authenticationCoordinator: AuthenticationCoordinator?
    
    private let dependencyContainer: DependencyContainer = MockedDependencyContainer()
    
    init() {
        navigationController.navigationBar.isHidden = true
    }
    
    var rootViewController: UIViewController? {
       return  navigationController
    }
    
    //MARK: - Methods
    
    func start(options connectionOptions: UIScene.ConnectionOptions?) {
        showAuthenticationFlow()
    }
    
    private func showAuthenticationFlow() {
        authenticationCoordinator = .init(navigationController: navigationController,
                                          authenticationService: dependencyContainer.authenticationService)
        authenticationCoordinator?.start(options: nil)
    }
    
}
