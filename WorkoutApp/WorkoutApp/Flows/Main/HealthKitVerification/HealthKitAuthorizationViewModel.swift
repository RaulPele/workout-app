//
//  HealthKitVerificationViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 10.05.2023.
//

import Foundation

extension HealthKitAuthorization.ContentView {
    
    class ViewModel: ObservableObject {
        
        let healthKitManager: HealthKitManager
        var authorizationTask: Task<Void, Never>?
        
        init(healthKitManager: HealthKitManager) {
            self.healthKitManager = healthKitManager
        }
        
        
        func authorize() {
            authorizationTask?.cancel()
            
            authorizationTask = Task(priority: .userInitiated) { @MainActor in
                do {
                    try await healthKitManager.requestPermissions()
                } catch {
                    print("Error while authorizint HealthKit: \(error.localizedDescription)")
                }
            }
        }
        
        
    }
}
