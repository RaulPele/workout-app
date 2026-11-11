//
//  ExerciseLibraryPickerViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 19.05.2026.
//

import Combine
import Foundation
import Observation

extension ExerciseLibraryPicker {

    @MainActor
    @Observable
    class ViewModel {

        // MARK: - Properties
        var definitions: [ExerciseDefinition] = []
        var searchText: String = ""
        var selectedExercise: Exercise?
        var showEditSetsSheet = false

        let libraryRepository: any UserExerciseLibraryRepositoryProtocol

        @ObservationIgnored private var cancellables = Set<AnyCancellable>()

        var displayedDefinitions: [ExerciseDefinition] {
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !query.isEmpty else { return definitions }
            return definitions.filter { $0.name.localizedStandardContains(query) }
        }

        var hasDefinitions: Bool { !definitions.isEmpty }

        // MARK: - Initializers
        init(libraryRepository: any UserExerciseLibraryRepositoryProtocol) {
            self.libraryRepository = libraryRepository
            subscribe()
            Task { try? await libraryRepository.loadData() }
        }

        // MARK: - Private Methods
        private func subscribe() {
            libraryRepository.entitiesPublisher
                .receive(on: RunLoop.main)
                .sink { [weak self] definitions in
                    self?.definitions = definitions
                }
                .store(in: &cancellables)
        }

        // MARK: - Handlers
        func handleTap(_ definition: ExerciseDefinition) {
            let exercise = Exercise(
                id: UUID(),
                definition: definition,
                numberOfSets: 3,
                setData: ExerciseSet(id: UUID(), reps: 10),
                restBetweenSets: 60
            )
            selectedExercise = exercise
            showEditSetsSheet = true
        }

        func handleDelete(_ definition: ExerciseDefinition) {
            Task { try? await libraryRepository.delete(entity: definition) }
        }
    }
}
