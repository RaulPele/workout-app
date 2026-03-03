//
//  WatchWorkoutAppApp.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 11.05.2023.
//

import SwiftUI

@main
struct WatchWorkoutApp_Watch_AppApp: App {

    @State private var workoutManager = WorkoutManager()

    var body: some Scene {
        WindowGroup {
            AppCoordinator()
                .sheet(isPresented: $workoutManager.showingSummaryView) {
                    SummaryView()
                }
                .environment(workoutManager)
        }
    }
}
