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
                    ActiveWorkoutView(template: route.workoutTemplate, workoutManager: workoutManager)
                }
        }
        .onChange(of: workoutManager.progress?.template.id, initial: true) { _, templateID in
            syncNavigation(withActiveTemplateID: templateID)
        }
    }

    // MARK: - Private Methods
    /// Pops back to the list when the workout is reset, and shows the active workout
    /// when one appears without a navigation push (e.g. after crash recovery).
    private func syncNavigation(withActiveTemplateID templateID: Workout.ID?) {
        if templateID == nil {
            navigationManager.popToRoot()
        } else if navigationManager.path.isEmpty, let template = workoutManager.progress?.template {
            navigationManager.push(WatchWorkoutSessionRoute(workoutTemplate: template))
        }
    }
}
