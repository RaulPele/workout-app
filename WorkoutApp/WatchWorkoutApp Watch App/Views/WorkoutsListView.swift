//
//  WorkoutsListView.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 11.05.2023.
//

import SwiftUI
import HealthKit
import WatchConnectivity
import OSLog

struct WorkoutsListView: View {

    @Environment(WorkoutManager.self) private var workoutManager

    let workoutType: HKWorkoutActivityType = .traditionalStrengthTraining

    var body: some View {
        List(workoutManager.workoutTemplates) { template in
            NavigationLink(value: WatchWorkoutSessionRoute(workoutTemplate: template)) {
                Text(template.name)
            }
        }
        .listStyle(.carousel)
        .overlay {
            if workoutManager.isLoading {
                ZStack {
                    Color.background.ignoresSafeArea()
                    ActivityIndicator(color: .primaryColor)
                }
            }
        }
        .task {
            await workoutManager.loadWorkoutTemplates()
        }
    }
}

extension HKWorkoutActivityType: Identifiable {
    public var id: UInt {
        rawValue
    }

    var name: String {
        switch self {
        case .traditionalStrengthTraining:
            return "Traditional Strength Training"

        default:
            return ""
        }
    }
}

#if DEBUG
#Preview {
    WorkoutsListView()
        .environment(WorkoutManager(phoneCommunicator: MockedPhoneCommunicator()))
}
#endif
