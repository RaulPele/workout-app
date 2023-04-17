//
//  AuthenticationCoordinator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 08.04.2023.
//

import Foundation
import UIKit

class AuthenticationCoordinator: Coordinator {
    
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    var rootViewController: UIViewController? {
        return navigationController
    }
    
    
    func start(options connectionOptions: UIScene.ConnectionOptions?) {
        showLoginScreen()
    }
    
    private func showLoginScreen() {
        let viewController = Login.ViewController()
        //TODO: inject viewmodel
        navigationController.pushViewController(viewController, animated: true)
    }
    
    
}
