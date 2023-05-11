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
            ScrollView {
                LazyVStack(spacing: 5) {
                    ForEach(viewModel.workouts) { workout in
                        Button {
                            viewModel.handleWorkoutTapped(for: workout)
                        } label: {
                            WorkoutCardView(workout: workout)
                        }.buttonStyle(.plain)
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
    
    static var previews: some View {
        ForEach(previewDevices) { device in
            Home.ContentView(viewModel: .init(workoutRepository: MockedWorkoutRepository(), healthKitManager: HealthKitManager()))
                .preview(device)
        }
    }
}
#endif
