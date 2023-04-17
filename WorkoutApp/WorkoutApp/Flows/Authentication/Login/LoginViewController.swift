//
// LoginViewController.swift
// WorkoutApp
//
// Created by Raul Pele on 08.04.2023.
//
//

import Foundation
import UIKit
import SwiftUI

extension Login {
    
    class ViewController: UIHostingController<ContentView> {
        
        let viewModel: ViewModel = ViewModel()
        
        init() {
            super.init(rootView: ContentView(viewModel: viewModel))
        }
        
        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
}
