//
//  MainCoordinator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.05.2023.
//

import Foundation
import UIKit

class MainCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    let workoutRepository: any WorkoutRepository
    let healthKitManager: HealthKitManager
    
    init(navigationController: UINavigationController,
         workoutRepository: any WorkoutRepository,
         healthKitManager: HealthKitManager) {
        
        self.navigationController = navigationController
        self.workoutRepository = workoutRepository
        self.healthKitManager = healthKitManager
    }
    
    var rootViewController: UIViewController? {
        return navigationController
    }
    
    func start(options connectionOptions: UIScene.ConnectionOptions?) {
        showHomeScreen()
    }
    
    func showHomeScreen() {
        let vc = Home.ViewController(workoutRepository: workoutRepository, healthKitManager: healthKitManager)
        vc.viewModel.onWorkoutTapped = showWorkoutDetailsScreen
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showWorkoutDetailsScreen(for workout: Workout) {
        let vc = WorkoutDetails.ViewController(workout: workout)
        vc.viewModel.onBack = { [unowned self] in
            navigationController.popViewController(animated: true)
            
        }
        navigationController.pushViewController(vc, animated: true)
    }
    
}
