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
                        WorkoutCardView(workout: workout)
                    }
                }
                .padding()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color.background)
            .onAppear(perform: viewModel.handleOnAppear)
        }
    }
}

#if DEBUG
struct Home_Preview: PreviewProvider {
    
    static var previews: some View {
        ForEach(previewDevices) { device in
            Home.ContentView(viewModel: .init(workoutRepository: MockedWorkoutRepository()))
                .preview(device)
        }
    }
}
#endif
