//
//  WatchWorkoutAppApp.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 11.05.2023.
//

import SwiftUI

@main
struct WatchWorkoutApp_Watch_AppApp: App {
    
    @StateObject private var workoutManager = WorkoutManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {

                WorkoutsListView()
//                MetricsView()
//                SessionPagingView()
            }
            .sheet(isPresented: $workoutManager.showingSummaryView) {
                SummaryView()
            }
            .environmentObject(workoutManager)
        }
    }
}
