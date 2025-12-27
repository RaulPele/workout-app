//
//  HealthKitVerificationCoordinator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 13.06.2023.
//

import Foundation
import SwiftUI

// HealthKitAuthorizationCoordinator is no longer needed as a separate coordinator
// HealthKitAuthorization.ContentView is used directly in RootCoordinatorView
// This file is kept for reference but the class is deprecated

// Legacy Coordinator class kept for reference but not used
class HealthKitAuthorizationCoordinator: Coordinator {
    
    var rootViewController: UIViewController? {
        return nil
    }
    
    func start(options connectionOptions: UIScene.ConnectionOptions?) {
        // No longer used - HealthKitAuthorization.ContentView is used directly in RootCoordinatorView
    }
}
