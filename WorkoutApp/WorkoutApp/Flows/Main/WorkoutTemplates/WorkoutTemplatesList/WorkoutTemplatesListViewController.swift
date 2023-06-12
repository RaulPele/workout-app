//
//  WorkoutTemplatesListViewController.swift
//  WorkoutApp
//
//  Created by Raul Pele on 29.05.2023.
//

import Foundation
import SwiftUI

extension WorkoutTemplatesList {
    
    class ViewController: UIHostingController<ContentView> {
        
        let viewModel = ViewModel()
        
        init() {
            super.init(rootView: ContentView(viewModel: viewModel))
            setupNavigation()
        }
        
        private func setupNavigation() {
            viewModel.navigateToTemplateBuilder =  { [weak self] in
                self?.navigateToTemplateBuilder()
            }
        }
        
        private func navigateToTemplateBuilder() {
            let vc = WorkoutTemplateBuilder.ViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        
        @MainActor required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
    }
}
