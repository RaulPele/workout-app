//
//  HKWorkout + Extensions.swift
//  WorkoutApp
//
//  Created by Raul Pele on 09.05.2023.
//

import Foundation
import HealthKit

extension HKWorkout {
    
    var basalEnergyBurned: Int? {
        return Int(ceil(statistics(for: .init(.basalEnergyBurned))?.sumQuantity()?.doubleValue(for: .largeCalorie()) ?? 0))
    }
    
    var activeEnergyBurned: Int? {
        return Int(ceil(statistics(for: .init(.activeEnergyBurned))?.sumQuantity()?.doubleValue(for: .largeCalorie()) ?? 0))
    }
    
    var totalCalories: Int? {
        guard let basalEnergyBurned, let activeEnergyBurned else { return nil }
        return basalEnergyBurned + activeEnergyBurned
    }
    
    var averageHeartRate: Int? { //TODO: test if this works
        return Int(ceil(statistics(for: .init(.heartRate))?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0))
    }
}
