//
//  WorkoutsFlowCoordinator.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 02.03.2026.
//

import SwiftUI

struct WorkoutsFlowCoordinator: View {

    // MARK: - Properties

    @State private var path = NavigationPath()
    @Environment(WorkoutManager.self) private var workoutManager

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $path) {
            WorkoutsListView()
                .navigationDestination(for: Workout.self) { template in
                    SessionPagingView()
                        .onAppear {
                            workoutManager.selectedWorkoutTemplate = template
                        }
                }
        }
    }
}
