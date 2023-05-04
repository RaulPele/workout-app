//
// HomeViewController.swift
// WorkoutApp
//
// Created by Raul Pele on 02.05.2023.
//
//

import Foundation
import UIKit
import SwiftUI

extension Home {
    
    class ViewController: UIHostingController<ContentView> {
        
        let viewModel: ViewModel
        
        init(workoutRepository: any WorkoutRepository) {
            viewModel = ViewModel(workoutRepository: workoutRepository)
            super.init(rootView: .init(viewModel: viewModel))
        }
        
        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
}
