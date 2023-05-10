//
//  HKWorkout + Extensions.swift
//  WorkoutApp
//
//  Created by Raul Pele on 09.05.2023.
//

import Foundation
import HealthKit

extension HKWorkout {
    
    var basalEnergyBurned: Double? {
        return statistics(for: .init(.basalEnergyBurned))?.sumQuantity()?.doubleValue(for: .largeCalorie())
    }
    
    var activeEnergyBurned: Double? {
        return statistics(for: .init(.activeEnergyBurned))?.sumQuantity()?.doubleValue(for: .largeCalorie())
    }
    
    var totalCalories: Double? {
        guard let basalEnergyBurned, let activeEnergyBurned else { return nil }
        return basalEnergyBurned + activeEnergyBurned
    }
}
