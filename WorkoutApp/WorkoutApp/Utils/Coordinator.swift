//
//  Coordinator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 25.03.2023.
//

import UIKit
import Combine

// Legacy Coordinator protocol - kept for backward compatibility
// All coordinators have been migrated to SwiftUI views
// This protocol is deprecated and no longer used in new code
@available(*, deprecated, message: "Use SwiftUI views instead. Coordinator pattern has been migrated to SwiftUI.")
protocol Coordinator: AnyObject {
    
    var rootViewController: UIViewController? { get }
    func start(options connectionOptions: UIScene.ConnectionOptions?)
}
