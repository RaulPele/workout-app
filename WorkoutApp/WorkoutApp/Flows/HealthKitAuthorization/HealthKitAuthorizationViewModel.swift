//
//  HealthKitAuthorizationViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 10.05.2023.
//

import Foundation
import HealthKit

extension HealthKitAuthorization.ContentView {
    
    @Observable class ViewModel {
        
        var isLoading = false
        
        let healthKitManager: HealthKitManager
        var authorizationTask: Task<Void, Never>?
        
        var onFinished: (() -> Void)?
        
        private let logger = CustomLogger(
            subsystem: Bundle.main.bundleIdentifier ?? "WorkoutApp",
            category: "HealthKitAuthorizationViewModel"
        )
        
        init(healthKitManager: HealthKitManager) {
            self.healthKitManager = healthKitManager
        }
        
        func checkAuthorizationStatus() {
            guard !isLoading else { return }
            
            if healthKitManager.isAuthorizedToShare() {
                onFinished?()
            }
        }
        
        func authorize() {
            authorizationTask?.cancel()
            isLoading = true
            
            authorizationTask = Task { @MainActor [weak self] in
                defer { self?.isLoading = false }
                do {
                    try await self?.healthKitManager.requestPermissions(fromWatch: false)
                    
                    if self?.healthKitManager.isAuthorizedToShare() == true {
                        self?.onFinished?()
                    }
                } catch {
                    self?.logger.error("Error while requesting HealthKit permissions: \(error.localizedDescription)")
                }
            }
        }
    }
}
