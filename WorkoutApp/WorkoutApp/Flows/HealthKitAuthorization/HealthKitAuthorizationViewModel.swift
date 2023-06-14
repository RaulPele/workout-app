//
//  HealthKitVerificationViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 10.05.2023.
//

import Foundation
import UIKit
import Combine


extension HealthKitAuthorization.ContentView {
    
    class ViewModel: ObservableObject {
        
        @Published var isLoading = false
        @Published var appCameInForeground = false
        
        let healthKitManager: HealthKitManager
        var authorizationTask: Task<Void, Never>?
        var loginTask: Task<Void, Never>?

        var onFinished: (() -> Void)?
        
        private var subscriptions = Set<AnyCancellable>()
        
        init(healthKitManager: HealthKitManager) {
            self.healthKitManager = healthKitManager
//            NotificationCenter.default.addObserver(self, selector: <#T##Selector#>, name: <#T##NSNotification.Name?#>, object: <#T##Any?#>)
            NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
                .sink { _ in
                    DispatchQueue.main.async {
                        self.appCameInForeground = true
                    }
                }
                .store(in: &subscriptions)
            NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
                .sink { _ in
                    DispatchQueue.main.async {
                        self.appCameInForeground = false
                    }
                }
                .store(in: &subscriptions)
        }
        
        func authorize() {
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }

            UIApplication.shared.open(settingsURL, options: [:]) { [weak self] _ in

            }
//            handleOnAppear()
        }
        
        func handleOnAppear() {
            authorizationTask?.cancel()
            isLoading = true
            
            authorizationTask = Task(priority: .high) { @MainActor [weak self] in
                guard let self = self else { return }
                
                do {
                    try await self.healthKitManager.requestPermissions(fromWatch: false)
                    if self.healthKitManager.isAuthorizedToShare() {
                        self.onFinished?()
                    }
                } catch {
                    print("Error while requesting permission: \(error.localizedDescription)")
                }
                isLoading = false
            }
            
        }
        
    }
}
