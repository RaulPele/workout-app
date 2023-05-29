//
//  MetricsAndExercisesView.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 29.05.2023.
//

import SwiftUI

struct MetricsAndExercisesView: View {
    
    enum Tab {
        case metrics
        case exercise1
        case exercise2
        
//        static func ==(lhs: Tab, rhs: Tab) -> Bool {
//            return lhs.id == rhs.id
//        }
    }
    
    @State var selection: Tab = .metrics
    
    var body: some View {
        TabView(selection: $selection) {
            MetricsView()
                .tag(Tab.metrics)
            CurrentExerciseView(currentExercise: .mockedBBBenchPress)
                .tag(Tab.exercise1)
            CurrentExerciseView(currentExercise: .mockedBBSquats)
                .tag(Tab.exercise2)
        }
        .tabViewStyle(.carousel)
    }
}
