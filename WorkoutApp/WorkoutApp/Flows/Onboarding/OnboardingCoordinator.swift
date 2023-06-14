//
//  OnboardingCoordinator.swift
//  WorkoutApp
//
//  Created by Raul Pele on 13.06.2023.
//

import Foundation
import SwiftUI

class OnboardingViewController: UIHostingController<OnboardingView> {
    
    private let viewModel: OnboardingView.ViewModel
    private let onFinishedOnboarding: () -> Void
    
    init(onFinishedOnboarding: @escaping () -> Void) {
        viewModel = OnboardingView.ViewModel()
        self.onFinishedOnboarding = onFinishedOnboarding
        super.init(rootView: OnboardingView(viewModel: viewModel))
        setupNavigation()
    }
    
    private func setupNavigation() {
        viewModel.onFinishedOnboarding = onFinishedOnboarding
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class OnboardingCoordinator: Coordinator {
    var rootViewController: UIViewController? {
        return navigationController
    }
    
    private let navigationController: UINavigationController
    private let onFinishedOnboarding: () -> Void
    
    
    init(navigationController: UINavigationController,
         onFinishedOnboarding: @escaping () -> Void) {
        
        self.onFinishedOnboarding = onFinishedOnboarding
        self.navigationController = navigationController
    }
    
    func start(options connectionOptions: UIScene.ConnectionOptions?) {
        let vc = OnboardingViewController(onFinishedOnboarding: onFinishedOnboarding)
        navigationController.pushViewController(vc, animated: true)
    }
}
