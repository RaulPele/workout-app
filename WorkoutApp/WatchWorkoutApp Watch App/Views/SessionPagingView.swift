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
    @Environment(WorkoutManager.self) private var workoutManager
    @State private var selection: Tab = .metrics

    var body: some View {
        TabView(selection: $selection) {
            ControlsView()
                .tag(Tab.controls)

            MetricsAndExercisesView()
                .tag(Tab.metrics)

            NowPlayingView()
                .tag(Tab.nowPlaying)
                .toolbar(.hidden)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: isLuminaceReduced ? .never : .automatic))
        .navigationTitle(workoutManager.selectedWorkoutTemplate?.name ?? "")
        .navigationBarBackButtonHidden(true)
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
