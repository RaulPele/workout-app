//
//  HealthKitManager.swift
//  WorkoutApp
//
//  Created by Raul Pele on 06.05.2023.
//

import Foundation
import HealthKit

class HealthKitManager {
    
    private let healthStore = HKHealthStore()
    private var errorMessage: String = ""
    
    func requestPermissions(fromWatch: Bool = false, completion: @escaping () -> ()) {
        let typesToShare: Set = [HKObjectType.workoutType()]
          
          let typesToRead: Set = [
              HKObjectType.quantityType(forIdentifier: .heartRate)!,
              HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
              HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
              HKObjectType.workoutType(),
              HKObjectType.activitySummaryType()
          ]
          
          healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
              DispatchQueue.main.async {
                  completion()
                  
                  if let error = error {
                      self.errorMessage = error.localizedDescription
                  }
              }
              
//              if !fromWatch {
//                  self.loadPreviousWorkouts { workouts in
//                      self.previousWorkouts = workouts
//                  }
//              }
          }
      }
    
    private func loadWorkouts(completion: @escaping ([HKWorkout]?, Error?) -> Void) {
            let workoutPredicate = HKQuery.predicateForWorkouts(with: .traditionalStrengthTraining)
            //TODO: add source predicate
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: .workoutType(),
                                      predicate: workoutPredicate,
                                      limit: 0,
                                      sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                DispatchQueue.main.async {
                    guard let samples = samples as? [HKWorkout], error == nil else {
                        completion(nil, error)
//                        continuation.resume(throwing: error!)
                        return
                        
                    }
//                    continuation.resume(returning: samples)
                    completion(samples, nil)
                }
            }
            
            healthStore.execute(query)
    }
    
    func loadWorkouts() async throws -> [HKWorkout] {
        return try await withCheckedThrowingContinuation { continuation in
            loadWorkouts { workouts, error in
                guard let workouts = workouts, error == nil else {
                    continuation.resume(throwing: error!)
                    return
                }
                continuation.resume(returning: workouts)
            }
        }
    }
    
    private func getAverageHeartRate(for workout: HKWorkout, completion: @escaping (Double?, Error?) -> Void) {
        let heartRatePredicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)
        let statisticsOptions = HKStatisticsOptions.discreteAverage
        let heartRateType = HKQuantityType(.heartRate)

        let query = HKStatisticsQuery(quantityType: heartRateType,
                                      quantitySamplePredicate: heartRatePredicate,
                                      options: statisticsOptions) { query, statistics, error in
            let averageHeartRate = statistics?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            guard let averageHeartRate, error == nil else {
                completion(nil, error)
                return
            }
            
            
            completion(ceil(averageHeartRate), nil)
        }
        
        healthStore.execute(query)
    }
    
    func getAverageHeartRate(for workout: HKWorkout) async throws -> Double {
        return try await withCheckedThrowingContinuation{ continuation in
            getAverageHeartRate(for: workout) { averageHeartRate, error in
                guard let averageHeartRate, error == nil else {
                    continuation.resume(throwing: error!)
                    return
                }
                continuation.resume(returning: averageHeartRate)
            }
        }
    }
}
