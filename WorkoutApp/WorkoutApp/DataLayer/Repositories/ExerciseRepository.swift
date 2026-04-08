//
//  ExerciseRepository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 18.06.2023.
//

import Combine
import Foundation

protocol ExerciseRepositoryProtocol: Repository where T == Exercise {}

class ExerciseRepository: ExerciseRepositoryProtocol {

    private var exercises = [Exercise]()
    private let exercisesSubject = CurrentValueSubject<[Exercise], Never>([])

    var entitiesPublisher: AnyPublisher<[Exercise], Never> {
        exercisesSubject.eraseToAnyPublisher()
    }

    func loadData() async throws {
        exercisesSubject.send(exercises)
    }

    func save(entity: Exercise) async throws {
        exercises.append(entity)
        exercisesSubject.send(exercises)
    }
}

class MockedExerciseRepository: ExerciseRepositoryProtocol {

    private var exercises = [Exercise]()
    private let exercisesSubject = CurrentValueSubject<[Exercise], Never>([])

    var entitiesPublisher: AnyPublisher<[Exercise], Never> {
        exercisesSubject.eraseToAnyPublisher()
    }

    func loadData() async throws {
        exercisesSubject.send(exercises)
    }

    func save(entity: Exercise) async throws {
        exercises.append(entity)
        exercisesSubject.send(exercises)
    }
}

