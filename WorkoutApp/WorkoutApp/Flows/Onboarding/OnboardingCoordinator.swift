//
//  OnboardingCoordinator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 13.06.2023.
//

import Foundation
import SwiftUI

// OnboardingCoordinator is no longer needed as a separate coordinator
// OnboardingView is used directly in RootCoordinatorView
// This file is kept for reference but the classes are deprecated

// Legacy Coordinator class kept for reference but not used
class OnboardingCoordinator: Coordinator {
    var rootViewController: UIViewController? {
        return nil
    }
    
    func start(options connectionOptions: UIScene.ConnectionOptions?) {
        // No longer used - OnboardingView is used directly in RootCoordinatorView
    }
}
