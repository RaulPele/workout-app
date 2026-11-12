//
//  WorkoutsFlowCoordinator.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 02.03.2026.
//

import SwiftUI

struct WorkoutsFlowCoordinator: View {

    // MARK: - Properties
    @State private var navigationManager = NavigationManager()
    @Environment(WorkoutManager.self) private var workoutManager

    // MARK: - Body
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            WorkoutsListView()
                .navigationDestination(for: WatchWorkoutSessionRoute.self) { route in
                    ActiveWorkoutView(workout: route.workoutTemplate)
                }
        }
        .onChange(of: workoutManager.showingSummaryView) { oldValue, newValue in
            if oldValue && !newValue {
                navigationManager.popToRoot() //TODO: should we move this somewhere else?
            }
        }
    }
}
