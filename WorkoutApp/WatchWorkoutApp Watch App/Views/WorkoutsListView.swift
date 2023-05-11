//
//  WorkoutsListView.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 11.05.2023.
//

import SwiftUI
import HealthKit

struct WorkoutsListView: View {
    
    @EnvironmentObject private var workoutManager: WorkoutManager
    let workoutType: HKWorkoutActivityType = .traditionalStrengthTraining
    var body: some View {
        List {
            NavigationLink(
                workoutType.name,
                destination: SessionPagingView(),
                tag: workoutType,
                selection: $workoutManager.selectedWorkout
            )
            .padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
        }
        .listStyle(.carousel)
        .navigationTitle("Workouts")
        .onAppear {
            workoutManager.requestAuthorization()
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

//struct WorkoutsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkoutsListView()
//    }
//}

//extension PreviewDevice {
//    let appleWatchSeries8: PreviewDevice = .init(rawValue: "Apple Watch Series 8")
//}
