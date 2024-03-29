//
//  SummaryView.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 11.05.2023.
//

import SwiftUI

struct SummaryView: View {
    
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) var dismiss
    
    @State private var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    var body: some View {
        if workoutManager.workout == nil {
            ProgressView("Saving Workout")
                .navigationBarHidden(true)
                .tint(.primaryColor)
        } else {
            ScrollView {
                VStack(alignment: .leading) {
                    SummaryMetricView(
                        title: "Total Time",
                        value: durationFormatter.string(from: workoutManager.workout?.duration ?? 0.0) ?? ""
                    )
                        .foregroundStyle(.yellow)
                    
                    SummaryMetricView(
                        title: "Total Energy",
                        value: Measurement(
                            value: workoutManager.workout?.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0,
                            unit: UnitEnergy.kilocalories
                        )
                        .formatted(
                            .measurement(
                                width: .abbreviated,
                                usage: .workout,
                                numberFormatStyle: .number.precision(.fractionLength(0))
                            )
                        )
                    )
                        .foregroundStyle(.pink)
                    
                    SummaryMetricView(
                        title: "Avg. Heart Rate",
                        value: workoutManager.averageHeartRate.formatted(.number.precision(.fractionLength(0))) + " bpm")
                        .foregroundStyle(.red)
                    
                    Text("Activity Rings")
                    
                    ActivityRingsView(healthStore: workoutManager.healthStore)
                        .frame(width: 50, height: 50)
                    
                    Button("Done") {
                        dismiss()
                    }
                    .tint(Color.primaryColor)
                }
                .scenePadding()
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SummaryMetricView: View {
    
    var title: String
    var value: String
    
    var body: some View {
        Text(title)
            .foregroundStyle(.foreground)
        Text(value)
            .font(.system(.title2, design: .rounded).lowercaseSmallCaps())
        Divider()
    }
}
//struct SummaryView_Previews: PreviewProvider {
//    static var previews: some View {
//        SummaryView()
//    }
//}
