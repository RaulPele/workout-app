//
//  HealthKitAuthorizationView.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 24.06.2023.
//

import SwiftUI

extension HealthKitAuthorizationView {

    @MainActor @Observable
    class ViewModel {

        var workoutManager: WorkoutManager?
        let onFinished: () -> Void

        init(onFinished: @escaping () -> Void) {
            self.onFinished = onFinished
        }

        func handleOnAppear() async {
            let status = workoutManager?.healthStore.authorizationStatus(for: .workoutType())
            if status == .sharingAuthorized {
                onFinished()
            } else if status == .notDetermined {
                await workoutManager?.requestAuthorization()
                checkAuthorization()
            }
        }

        func checkAuthorization() {
            let status = workoutManager?.healthStore.authorizationStatus(for: .workoutType())
            if status == .sharingAuthorized {
                onFinished()
            }
        }
    }
}

struct HealthKitAuthorizationView: View {

    @Environment(WorkoutManager.self) private var workoutManager
    @State private var viewModel: ViewModel

    init(onFinished: @escaping () -> Void) {
        self._viewModel = State(wrappedValue: ViewModel(onFinished: onFinished))
    }

    var body: some View {
        Text("\(Constants.appName) is not authorized to access HealthKit. Open Health and grant permissions.")
            .font(.headline)
            .foregroundStyle(Color.onBackground)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .task {
                viewModel.workoutManager = workoutManager
                await viewModel.handleOnAppear()
            }
    }
}
