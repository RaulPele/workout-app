//
//  AppCoordinator.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 24.06.2023.
//

import SwiftUI

struct AppCoordinator: View {

    enum Flow {
        case authorization
        case main
    }

    @State private var currentFlow: Flow?
    @Environment(WorkoutManager.self) private var workoutManager

    var body: some View {
        Group {
            switch currentFlow {
            case .authorization:
                HealthKitAuthorizationView {
                    currentFlow = .main
                }

            case .main:
                WorkoutsFlowCoordinator()
            default:
                EmptyView()
            }
        }
        .onAppear() {
            determineCurrentFlow()
        }
    }

    private func determineCurrentFlow() {
        let status = workoutManager.healthStore.authorizationStatus(for: .workoutType())
        switch status {
        case .notDetermined, .sharingDenied:
            currentFlow = .authorization
        case .sharingAuthorized:
            currentFlow = .main
        @unknown default:
            break
        }
    }
}
