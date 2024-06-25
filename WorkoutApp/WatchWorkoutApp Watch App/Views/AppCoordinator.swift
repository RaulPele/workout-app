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
    
    @State private var selection: [Flow] = []
    @State private var path = NavigationPath()
    @EnvironmentObject private var workoutManager: WorkoutManager
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                
                NavigationLink(value: Flow.authorization) {
                   Text("Authorization Flow")
                }
                
                NavigationLink(value: Flow.main) {
                    Text("Main Flow")
                }

            }
            .navigationDestination(for: Flow.self) { flow in
                switch flow {
                case .authorization:
                    HealthKitAuthorizationView() {
                        selection = [.main]
                    }
                    .navigationBarBackButtonHidden()
                    
                case .main:
                    WorkoutsListView()
                        .navigationBarBackButtonHidden()
                }
            }
//            .navigationDestination(for: WorkoutTemplate.self) { template in
//                SessionPagingView()
//            }
        }
        .onAppear {
            handleOnAppear()
        }
//        NavigationStack(path: $path) {
//            NavigationLink {
//                SessionPagingView()
//                    .navigationTitle("QWEQWE")
//
//            } label: {
//                Text("2")
//            }

//            SessionPagingView()
//            VStack {
//                NavigationLink(value: Flow.main) {
//                    Text("1")
//                }
//                Text("2")
//                    .onTapGesture {
//                        path.append(Flow.main)
//                    }

//            }
//            .navigationDestination(for: Flow.self) { flow in
//                SessionPagingView()
//            }
        
//        }
    }
    
    func handleOnAppear() {
        let status = workoutManager.healthStore.authorizationStatus(for: .workoutType())
        switch status {
        case  .notDetermined, .sharingDenied:
//            selection = [.authorization]
            path.append(Flow.authorization)
        case .sharingAuthorized:
//            selection = [.main]
            path.append(Flow.main)
            
        @unknown default:
            break
        }
    }
}
