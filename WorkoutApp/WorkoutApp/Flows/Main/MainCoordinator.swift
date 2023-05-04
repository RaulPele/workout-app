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
    
    init(navigationController: UINavigationController,
         workoutRepository: any WorkoutRepository) {
        
        self.navigationController = navigationController
        self.workoutRepository = workoutRepository
    }
    
    var rootViewController: UIViewController? {
        return navigationController
    }
    
    func start(options connectionOptions: UIScene.ConnectionOptions?) {
        showHomeScreen()
    }
    
    func showHomeScreen() {
        let vc = Home.ViewController(workoutRepository: workoutRepository)
        navigationController.pushViewController(vc, animated: true)
    }
    
}
