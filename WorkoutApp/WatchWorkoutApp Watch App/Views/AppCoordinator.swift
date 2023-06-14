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
    
    @State private var selection: Flow?
    @EnvironmentObject private var workoutManager: WorkoutManager
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(
                    tag: Flow.authorization,
                    selection: $selection
                ) {
                    HealthKitAuthorizationView() {
                        selection = .main
                    }
                    .navigationBarBackButtonHidden()
                } label: {
                    Text("Authorization")
                }
                
                NavigationLink(
                    tag: Flow.main,
                    selection: $selection
                ) {
                    WorkoutsListView()
                        .navigationBarBackButtonHidden()

                } label: {
                    Text("Main")
                }
            }
        }
        .onAppear {
            handleOnAppear()
        }
    }
    
    func handleOnAppear() {
        let status = workoutManager.healthStore.authorizationStatus(for: .workoutType())
        switch status {
        case  .notDetermined, .sharingDenied:
            selection = .authorization
        case .sharingAuthorized:
            selection = .main
        @unknown default:
            break
        }
    }
}
