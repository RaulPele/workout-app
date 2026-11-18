//
//  WorkoutRepository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.05.2023.
//

import Combine
import Foundation

protocol WorkoutSessionRepository: Repository where T == WorkoutSession {}

// MARK: - SwiftDataConvertible
extension WorkoutSession: SwiftDataConvertible {

    var dto: WorkoutSessionDTO {
        WorkoutSessionDTO(from: self)
    }

    func update(_ existingDTO: WorkoutSessionDTO) {
        existingDTO.title = title
        existingDTO.workoutTemplate = workoutTemplate
        existingDTO.performedExercises = performedExercises
        existingDTO.averageHeartRate = averageHeartRate
        existingDTO.duration = duration
        existingDTO.startDate = startDate
        existingDTO.endDate = endDate
        existingDTO.totalCalories = totalCalories
        existingDTO.activeCalories = activeCalories
    }
}

// MARK: - WorkoutSessionAPIRepository
class WorkoutSessionAPIRepository: WorkoutSessionRepository {

    // MARK: - Properties
    private let localDataSource = SwiftDataDataSource<WorkoutSession>()
    private let sessionsSubject = CurrentValueSubject<[WorkoutSession], Never>([])

    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? "WorkoutApp",
        category: "WorkoutSessionRepository"
    )

    var entitiesPublisher: AnyPublisher<[WorkoutSession], Never> {
        sessionsSubject.eraseToAnyPublisher()
    }

    // MARK: - Public Methods
    /// Publishes every stored session. SwiftData is the source of truth: sessions arrive
    /// from the watch before HealthKit has synced the matching workout to the phone, so
    /// gating on HealthKit would hide a just-finished workout.
    func loadData() async throws {
        let sessions: [WorkoutSession] = try await localDataSource.fetchAll()
        sessionsSubject.send(sessions)
    }

    func save(entity: WorkoutSession) async throws {
        logger.debug("Saving workout session: \(entity.title ?? "untitled") (ID: \(entity.id))")
        do {
            try await localDataSource.save(entity: entity)
            logger.info("Successfully saved workout session (ID: \(entity.id))")
            try await loadData()
        } catch {
            logger.error("Failed to save workout session (ID: \(entity.id)), error: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - MockedWorkoutSessionRepository
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

// MARK: - MockedWorkoutSessionEmptyRepository
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
