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
    
    @EnvironmentObject private var workoutManager: WorkoutManager
    
    let workoutType: HKWorkoutActivityType = .traditionalStrengthTraining
    @State private var isLoading = false //TODO: create viewmodel
    
    var body: some View {
        NavigationSplitView {
            List(workoutManager.workoutTemplates, selection: $workoutManager.selectedWorkoutTemplate) { template in
                NavigationLink(value: template) {
                    Text(template.name)
                }
            }
            .listStyle(.carousel)
            .overlay {
                if workoutManager.isLoading {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        ActivityIndicator(color: .primaryColor)
                    }
                }
            }
            .onAppear {
                workoutManager.isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    workoutManager.loadWorkoutTemplates()
                }
            }
        } detail: {
            SessionPagingView()
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
        .environmentObject(WorkoutManager())
}
#endif
