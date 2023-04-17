//
//  Coordinator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 25.03.2023.
//

import UIKit

protocol Coordinator: AnyObject {
    
    var rootViewController: UIViewController? { get } //TODO: do we need navigation controller here?
    func start(options connectionOptions: UIScene.ConnectionOptions?)
}
