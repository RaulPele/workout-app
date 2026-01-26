//
//  NavigationManager.swift
//  WorkoutApp
//
//  Created by Raul Pele on [Date]
//

import SwiftUI

/// Protocol defining navigation operations for managing navigation paths
protocol NavigationManagerProtocol {
    var path: NavigationPath { get set }
    
    func push<Route: Hashable>(_ route: Route)
    func pop()
    func popToRoot()
}

/// Base navigation manager class that holds NavigationPath state
@Observable
class NavigationManager: NavigationManagerProtocol {
    var path = NavigationPath()
    
    func push<Route: Hashable>(_ route: Route) {
        path.append(route)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}

/// Navigation manager for Workout Sessions tab
@Observable
class WorkoutSessionsNavigationManager: NavigationManager {}

/// Navigation manager for Workout Templates tab
@Observable
class WorkoutTemplatesNavigationManager: NavigationManager {
    
    enum Screens {
        case workoutsList
        case workoutsBuilderView(Workout?)
    }
}

/// Navigation manager for Authentication flow
@Observable
class AuthenticationNavigationManager: NavigationManager {}

