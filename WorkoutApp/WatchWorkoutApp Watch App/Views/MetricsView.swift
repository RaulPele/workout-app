//
//  MetricsView.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 11.05.2023.
//

import SwiftUI

struct MetricsView: View {
    
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        TimelineView(
            MetricsTimelineSchedule(
                from: workoutManager.builder?.startDate ?? Date(),
                isPaused: workoutManager.session?.state == .paused
            )
        ) { context in
            VStack(alignment: .leading) {
                
                Group {
                    ElapsedTimeView(
                        elapsedTime: workoutManager.builder?.elapsedTime(at: context.date) ?? 0,
                        showSubseconds: context.cadence == .live
                    )
                    .foregroundStyle(.yellow)
                    Text(
                        Measurement(
                            value: workoutManager.activeEnergyBurned,
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
                    Text(workoutManager.heartRate.formatted(.number.precision(.fractionLength(0))) + " bpm")
                }
                .font(
                    .system(
                        .title2,
                        design: .rounded
                    ).monospacedDigit().lowercaseSmallCaps())
                
            }
            
            .frame(maxWidth: .infinity, alignment: .leading)
//            .ignoresSafeArea(edges: .bottom)
            .scenePadding()
//            .navigationTitle("www")
        }
    }
}

//struct MetricsView_Previews: PreviewProvider {
//    static var previews: some View {
//        MetricsView()
//    }
//}

private struct MetricsTimelineSchedule: TimelineSchedule {
    
    var startDate: Date
    var isPaused: Bool
    
    init(from startDate: Date, isPaused: Bool) {
        self.startDate = startDate
        self.isPaused = isPaused
    }
    
    func entries(from startDate: Date, mode: TimelineScheduleMode) -> AnyIterator<Date> {
        var baseSchedule = PeriodicTimelineSchedule(from: self.startDate,
                                                    by: (mode == .lowFrequency ? 1.0 : 1.0 / 30.0))
            .entries(from: startDate, mode: mode)
        
        return AnyIterator<Date> {
            guard !isPaused else { return nil }
            return baseSchedule.next()
        }
    }
}
