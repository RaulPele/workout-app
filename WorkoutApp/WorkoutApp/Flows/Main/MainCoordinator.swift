//
//  MainCoordinator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.05.2023.
//

import Foundation
import UIKit
import SwiftUI

class MainCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    let workoutRepository: any WorkoutRepository
    let healthKitManager: HealthKitManager
    private let exerciseService: any ExerciseServiceProtocol
    private let workoutTemplateService: any WorkoutTemplateServiceProtocol
    
    let tabBarController: UITabBarController
    
    init(navigationController: UINavigationController,
         workoutRepository: any WorkoutRepository,
         healthKitManager: HealthKitManager,
         exerciseService: any ExerciseServiceProtocol,
         workoutTemplateService: any WorkoutTemplateServiceProtocol) {
        
        self.navigationController = navigationController
        self.workoutRepository = workoutRepository
        self.healthKitManager = healthKitManager
        self.exerciseService = exerciseService
        self.workoutTemplateService = workoutTemplateService
        
        tabBarController = .init()
    }
    
    var rootViewController: UIViewController? {
        return navigationController
    }
    
    func start(options connectionOptions: UIScene.ConnectionOptions?) {
//        showHomeScreen()
        configureTabBarController()
        navigationController.setViewControllers([tabBarController], animated: true)
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
    
    //MARK: - Tab bar controller
    private func configureTabBarController() {
        let tabs: [TabBarItem] = [.workoutSessions, .workoutTemplates]
        let controllers: [UINavigationController] = tabs
            .map { getViewController(for: $0) }
            .map {
                let navController = UINavigationController(rootViewController: $0)
                navController.isNavigationBarHidden = true
                
                return navController
            }
        
        tabBarController.viewControllers = controllers
        tabBarController.selectedIndex = 0
        
        tabBarController.tabBar.isMultipleTouchEnabled = false
        
        let tabBarItemAppearance = UITabBarItemAppearance()
        let tabBarAppearance = UITabBarAppearance()
        
        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
        tabBarAppearance.configureWithOpaqueBackground()

        tabBarAppearance.backgroundColor = UIColor(Color.surface2)
        
        tabBarController.tabBar.standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = tabBarAppearance
        }
        tabBarController.tabBar.unselectedItemTintColor = UIColor(Color.onSurface)
        tabBarController.tabBar.tintColor = UIColor(Color.primaryColor)

        
    }
    
    private func getViewController(for tab: TabBarItem) -> UIViewController {
        var vc: UIViewController
        
        switch tab {
        case .workoutSessions:
            vc = Home.ViewController(workoutRepository: workoutRepository, healthKitManager: healthKitManager)
        case .workoutTemplates:
            vc = WorkoutTemplatesList.ViewController(exerciseService: exerciseService, workoutTemplateService: workoutTemplateService)
        }
        
        vc.tabBarItem.image = tab.icon(isSelected: false)
        vc.tabBarItem.selectedImage = tab.icon(isSelected: true)
        vc.tabBarItem.title = tab.title
        return vc
    }
    
}

enum TabBarItem {
    
    case workoutSessions
    case workoutTemplates
    
    var title: String {
        switch self {
        case .workoutSessions:
            return "Sessions"
        case .workoutTemplates:
            return "Templates"
        }
    }
    
    func icon(isSelected: Bool) -> UIImage? {
        var image: UIImage?
        
        switch self {
        case .workoutSessions:
            image = UIImage(systemName: "dumbbell")
        case .workoutTemplates:
            image = UIImage(systemName: "list.bullet.clipboard")
        }
        
        if isSelected {
            return image?.withTintColor(UIColor(Color.primaryColor), renderingMode: .alwaysOriginal)
        }
        return image?.withTintColor(.white.withAlphaComponent(0.9), renderingMode: .alwaysOriginal)
    }
    
}
