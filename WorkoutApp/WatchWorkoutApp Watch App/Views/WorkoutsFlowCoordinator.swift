//
//  WorkoutsFlowCoordinator.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 02.03.2026.
//

import SwiftUI

struct WorkoutsFlowCoordinator: View {

    // MARK: - Properties

    @State private var navigationManager = WatchWorkoutsNavigationManager()
    @Environment(WorkoutManager.self) private var workoutManager

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            WorkoutsListView()
                .navigationDestination(for: WatchWorkoutSessionRoute.self) { route in
                    SessionPagingView(workoutTemplate: route.workoutTemplate)
                }
        }
        .onChange(of: workoutManager.showingSummaryView) { oldValue, newValue in
            if oldValue && !newValue {
                navigationManager.popToRoot()
            }
        }
    }
}
