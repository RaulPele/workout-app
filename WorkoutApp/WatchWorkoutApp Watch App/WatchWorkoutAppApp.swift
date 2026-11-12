//
//  WatchWorkoutAppApp.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 11.05.2023.
//

import SwiftUI

@main
struct WatchWorkoutApp_Watch_AppApp: App {

    // MARK: - Properties
    @State private var workoutManager = WorkoutManager()

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            AppCoordinator()
                .sheet(isPresented: summaryBinding) {
                    SummaryView() //TODO: improve summary view!
                }
                .environment(workoutManager)
        }
    }

    // MARK: - Private Properties
    private var summaryBinding: Binding<Bool> {
        Binding(
            get: { workoutManager.isShowingSummary },
            set: { isPresented in
                if !isPresented {
                    workoutManager.dismissSummary()
                }
            }
        )
    }
}
