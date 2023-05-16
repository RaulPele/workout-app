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
//    @StateObject private var viewModel = WorkoutsListViewModel()
    
//    init() {
//        self._viewModel = .init(wrappedValue: WorkoutsListViewModel(workoutManager: WorkoutManager()))
//    }
    
    let workoutType: HKWorkoutActivityType = .traditionalStrengthTraining
    
    var body: some View {
        List {
            ForEach(workoutManager.workoutTemplates) { template in
                NavigationLink(
                    template.name,
                    destination: SessionPagingView(),
                    tag: workoutType,
                    selection: $workoutManager.selectedWorkout
                )
            }
            
            .padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
            
            Button("Request templates") {
                workoutManager.loadWorkoutTemplates()
            }
        }
        .listStyle(.carousel)
        .navigationTitle("Workouts")
        .onAppear {
            workoutManager.requestAuthorization() //TODO: create a separate authorization screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                workoutManager.loadWorkoutTemplates()
            }
            
//            let logger = Logger()
//            print("TEST SENDING MESSAGE")
//            logger.log("TEST SENDING MESSAGE")
//
//            let session = WCSession.default
//            let message = try JSONEncoder().encode("This is a message")
//            session.sendMessageData(message) { response in
//                print("RESPONSE: response")
//            }
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
