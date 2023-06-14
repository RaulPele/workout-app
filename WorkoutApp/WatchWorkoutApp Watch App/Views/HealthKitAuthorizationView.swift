//
//  HealthKitAuthorizationView.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 24.06.2023.
//

import SwiftUI

extension HealthKitAuthorizationView {
    
    class ViewModel: ObservableObject {
        
        var workoutManager: WorkoutManager?
        let onFinished: () -> Void
        
        init(onFinished: @escaping () -> Void) {
            self.onFinished = onFinished
        }
        
        func handleOnAppear() {
            let status = workoutManager?.healthStore.authorizationStatus(for: .workoutType())
            if status == .sharingAuthorized {
                onFinished()
            } else if status == .notDetermined {
                workoutManager?.requestAuthorization(onFinished: { [weak self] in
                    self?.checkAuthorization()
                })
                
            }
        }
        
        func checkAuthorization() {
            let status = workoutManager?.healthStore.authorizationStatus(for: .workoutType())
            if status == .sharingAuthorized {
                onFinished()
            }
        }
    }
}

struct HealthKitAuthorizationView: View {
    
    @EnvironmentObject private var workoutManager: WorkoutManager
    @StateObject private var viewModel: ViewModel
    
    init(onFinished: @escaping () -> Void) {
        self._viewModel = StateObject(wrappedValue: ViewModel(onFinished: onFinished))
    }
    
    
    var body: some View {
        Text("\(Constants.appName) is not authorized to access HealthKit. Open Health and grant permissions.")
            .font(.headline)
            .foregroundColor(Color.onBackground)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .onAppear {
                viewModel.workoutManager = workoutManager
                viewModel.handleOnAppear()
            }
        
    }
}
