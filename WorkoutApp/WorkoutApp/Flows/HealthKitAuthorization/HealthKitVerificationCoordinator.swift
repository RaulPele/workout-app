//
//  HealthKitVerificationCoordinator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 13.06.2023.
//

import Foundation
import SwiftUI

class HealthKitAuthorizationCoordinator: Coordinator {
    
    var rootViewController: UIViewController? {
        return navigationController
    }
    
    private let navigationController: UINavigationController
    private let healthKitManager: HealthKitManager
    private let onFinished: () -> Void
    
    init(navigationController: UINavigationController, healthKitManager: HealthKitManager, onFinished: @escaping () -> Void) {
        self.navigationController = navigationController
        self.onFinished = onFinished
        self.healthKitManager = healthKitManager
    }
    
    func start(options connectionOptions: UIScene.ConnectionOptions?) {
        let vc = HealthKitAuthorization.ViewController(healthKitManager: healthKitManager, onFinished: onFinished)
        navigationController.pushViewController(vc, animated: true)
    }
}
