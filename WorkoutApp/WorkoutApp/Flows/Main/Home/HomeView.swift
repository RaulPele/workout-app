//
// HomeView.swift
// WorkoutApp
//
// Created by Raul Pele on 02.05.2023.
//
//

import Foundation
import SwiftUI

struct Home {
    
    struct ContentView: View {
        
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            if viewModel.workouts.isEmpty {
                Text("You don't have any workouts tracked. Open the watch application and get started!")
                    .multilineTextAlignment(.center)
                    .font(.heading1)
                    .foregroundColor(.onBackground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.background)
                    .onAppear {
                        viewModel.handleOnAppear()
                    }
                    .overlay {
                        loadingView
                    }
            } else {
                ScrollView {
                    LazyVStack(alignment:.leading, spacing: 10) {
                        
                        Text("Workout sessions")
                            .foregroundColor(.onBackground)
                            .font(.heading1)
                            .padding(.bottom, 10)
                        ForEach(viewModel.workouts) { workout in
                            Button {
                                viewModel.handleWorkoutTapped(for: workout)
                            } label: {
                                WorkoutCardView(workout: workout)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .background(Color.background)
                .onAppear(perform: viewModel.handleOnAppear)
                .overlay {
                    loadingView
                }
            }
        }
        
        @ViewBuilder
        private var loadingView: some View {
            if viewModel.isLoading {
                ZStack {
                    Color.black
                    ActivityIndicator(color: .red, scale: 2)
                }
                .ignoresSafeArea()
            }
        }
    }
}

#if DEBUG
struct Home_Preview: PreviewProvider {
    
    struct HomeNoWorkoutsTestView: View {
        
        @StateObject private var viewModel: Home.ViewModel = .init(
            workoutRepository: MockedWorkoutSessionEmptyRepository(),
            healthKitManager: HealthKitManager()
        )
        
        init() {
            viewModel.workouts = []
        }
        
        var body: some View {
            Home.ContentView(viewModel: viewModel)
        }
    }
    
    struct HomeTestView: View {
        
        @StateObject private var viewModel: Home.ViewModel
        
        init() {
            self._viewModel = .init(wrappedValue: .init(
                workoutRepository: MockedWorkoutSessionRepository(),
                healthKitManager: HealthKitManager()))
            viewModel.workouts = WorkoutSession.mockedSet
        }
        
        var body: some View {
            Home.ContentView(viewModel: viewModel)
                .onAppear {
                    viewModel.workouts = WorkoutSession.mockedSet
                }
        }
    }
    
    static var previews: some View {
        ForEach(previewDevices) { device in
            HomeTestView()
                .preview(device)
                
        }
        
        ForEach(previewDevices) { device in
            HomeNoWorkoutsTestView()
                .preview(device)
        }
    }
}
#endif
