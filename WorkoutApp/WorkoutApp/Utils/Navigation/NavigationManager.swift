//
//  NavigationManager.swift
//  WorkoutApp
//
//  Created by Raul Pele on [Date]
//

import Foundation
import SwiftUI

/// Protocol defining navigation operations for managing navigation paths
protocol NavigationManagerProtocol: ObservableObject {
    var path: NavigationPath { get set }
    
    func push<Route: Hashable>(_ route: Route)
    func pop()
    func popToRoot()
}

/// Base navigation manager class that holds NavigationPath state
class NavigationManager: NavigationManagerProtocol {
    @Published var path = NavigationPath()
    
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
class WorkoutSessionsNavigationManager: NavigationManager {}

/// Navigation manager for Workout Templates tab
class WorkoutTemplatesNavigationManager: NavigationManager {}

/// Navigation manager for Authentication flow
class AuthenticationNavigationManager: NavigationManager {}

