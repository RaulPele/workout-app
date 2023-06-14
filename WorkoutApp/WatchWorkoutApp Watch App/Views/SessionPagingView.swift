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
    @State private var selection2: Tab = .metrics
    enum Tab {
        case metrics
        case nowPlaying
        case controls
    }
    
    var body: some View {
        TabView(selection: $selection) {
            ControlsView().tag(Tab.controls)
            
//            MetricsView()
            MetricsAndExercisesView()
                .tag(Tab.metrics)
            
            NowPlayingView().tag(Tab.nowPlaying)
        }
        .navigationTitle(workoutManager.selectedWorkoutTemplate?.name ?? "")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(selection == .nowPlaying)
//        .navigationBarHidden(true)
        .onChange(of: workoutManager.running) { _ in
            displayMetricsView()
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: isLuminaceReduced ? .never : .automatic))
        .onChange(of: isLuminaceReduced) { newValue in
            displayMetricsView()
        }
    }
    
    private func displayMetricsView() {
        withAnimation {
            selection = .metrics
        }
    }
}

//struct SessionPagingView_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionPagingView()
//            .environmentObject(WorkoutManager())
//    }
//}
