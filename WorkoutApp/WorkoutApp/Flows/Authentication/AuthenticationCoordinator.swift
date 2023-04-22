//
//  AuthenticationCoordinator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 08.04.2023.
//

import Foundation
import UIKit

class AuthenticationCoordinator: Coordinator {
    
    private let navigationController: UINavigationController
    
    private let authenticationService: AuthenticationServiceProtocol
    
    init(navigationController: UINavigationController,
         authenticationService: AuthenticationServiceProtocol) {
        self.navigationController = navigationController
        self.authenticationService = authenticationService
    }
    
    var rootViewController: UIViewController? {
        return navigationController
    }
    
    func start(options connectionOptions: UIScene.ConnectionOptions?) {
        showAccountVerificationScreen()
    }
    
    private func showAccountVerificationScreen() {
        let viewController = AccountVerification.ViewController(authenticationService: authenticationService)
        viewController.viewModel.onAccountChecked = { [weak self] accountStatus, email in
            self?.handleAccountChecked(status: accountStatus, email: email)
        }
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showLoginScreen(email: String) {
        let viewController = Login.ViewController(authenticationService: authenticationService)
        viewController.viewModel.email = email
        //TODO: inject viewmodel??
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showRegisterScreen() {
        
    }
    
    private func handleAccountChecked(status: AccountStatus, email: String) {
        switch status {
        case .inactive:
            //TODO: redirect to register flow
            showRegisterScreen()
        case .active:
            showLoginScreen(email: email)
        }
    }
}
