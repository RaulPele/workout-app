//
//  SessionPagingView.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 11.05.2023.
//

import SwiftUI
import WatchKit

struct SessionPagingView: View {
    
    @Environment(\.isLuminanceReduced) var isLuminaceReduced
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selection: Tab = .metrics
    
    var body: some View {
        TabView(selection: $selection) {
            ControlsView()
                .tag(Tab.controls)
            
//            VStack {
//                Color.blue
                MetricsAndExercisesView()
//                    .layoutPriority(1)
//            }
            .tag(Tab.metrics)
            
            NowPlayingView()
                .tag(Tab.nowPlaying)
                .toolbar(.hidden)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: isLuminaceReduced ? .never : .automatic))
        .navigationTitle(workoutManager.selectedWorkoutTemplate?.name ?? "")
        .navigationBarBackButtonHidden(true)
        //        .navigationBarHidden(selection == .nowPlaying)
        .onChange(of: workoutManager.running) { _, _ in
            displayMetricsView()
        }
        .onChange(of: isLuminaceReduced) { _, _ in
            displayMetricsView()
        }
    }
    
    private func displayMetricsView() {
        withAnimation {
            selection = .metrics
        }
    }
    
    enum Tab {
        case metrics
        case nowPlaying
        case controls
    }
}

//struct SessionPagingView_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionPagingView()
//            .environmentObject(WorkoutManager())
//    }
//}
