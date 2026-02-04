//
//  WorkoutRepository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.05.2023.
//

import Combine
import Foundation
import HealthKit

protocol WorkoutSessionRepository: Repository where T == WorkoutSession {}

class WorkoutSessionAPIRepository: WorkoutSessionRepository {

    private let healthKitManager: HealthKitManager
    private let sessionsSubject = CurrentValueSubject<[WorkoutSession], Never>([])

    var entitiesPublisher: AnyPublisher<[WorkoutSession], Never> {
        sessionsSubject.eraseToAnyPublisher()
    }

    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
    }

    func loadData() async throws {
        let hkWorkouts = try await healthKitManager.loadWorkouts()
        let workouts: [WorkoutSession] = hkWorkouts.compactMap { hkWorkout in
            try? FileIOManager.read(forId: hkWorkout.uuid, fromDirectory: .workoutSessions)
        }
        sessionsSubject.send(workouts)
    }

    func save(entity: WorkoutSession) async throws {
        try FileIOManager.write(entity: entity, toDirectory: .workoutSessions)
        try await loadData()
    }
}

class MockedWorkoutSessionRepository: WorkoutSessionRepository {

    private let sessionsSubject = CurrentValueSubject<[WorkoutSession], Never>([])

    var entitiesPublisher: AnyPublisher<[WorkoutSession], Never> {
        sessionsSubject.eraseToAnyPublisher()
    }

    func loadData() async throws {
        sessionsSubject.send(WorkoutSession.mockedSet)
    }

    func save(entity: WorkoutSession) async throws {
        try await loadData()
    }
}

class MockedWorkoutSessionEmptyRepository: WorkoutSessionRepository {

    private let sessionsSubject = CurrentValueSubject<[WorkoutSession], Never>([])

    var entitiesPublisher: AnyPublisher<[WorkoutSession], Never> {
        sessionsSubject.eraseToAnyPublisher()
    }

    func loadData() async throws {
        sessionsSubject.send([])
    }

    func save(entity: WorkoutSession) async throws {
        try await loadData()
    }
}
