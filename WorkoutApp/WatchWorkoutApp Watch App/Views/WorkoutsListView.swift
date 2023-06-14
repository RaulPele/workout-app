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

//class WorkoutsListViewModel: ObservableObject {
//    
//    @Published var workoutTemplates = [WorkoutTemplate]()
////    @Published workoutManger
////    private var phoneCommunicator = PhoneCommunicator()
//    
//    
//    init() {
////        self.workoutManager = workoutManager
//    }
//    
//    func loadWorkoutTemplates() {
//        do {
//            try phoneCommunicator.requestWorkoutTemplates { [weak self] templates in
//                DispatchQueue.main.async {
//                    self?.workoutTemplates = templates
//                }
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//    
//}

struct WorkoutsListView: View {
    
    @EnvironmentObject private var workoutManager: WorkoutManager
    
    let workoutType: HKWorkoutActivityType = .traditionalStrengthTraining
    @State private var isLoading = false //TODO: create viewmodel
    
    var body: some View {
        List {
            ForEach(workoutManager.workoutTemplates) { template in
                NavigationLink(
                    template.name,
                    destination: SessionPagingView(),
                    tag: template,
                    selection: $workoutManager.selectedWorkoutTemplate
                )
            }
            .padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
        }
        .listStyle(.carousel)
        .navigationTitle("Workouts")
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
