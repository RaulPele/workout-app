//
//  ExerciseLibraryViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import Combine
import Foundation
import Observation

// MARK: - ExerciseLibraryViewModel
@MainActor
@Observable
final class ExerciseLibraryViewModel {

    // MARK: - Sheet
    enum Sheet: Identifiable {
        case create
        case edit(ExerciseDefinition)

        var id: String {
            switch self {
            case .create: "create"
            case .edit(let definition): "edit-\(definition.id)"
            }
        }

        var definition: ExerciseDefinition? {
            if case .edit(let definition) = self { return definition }
            return nil
        }
    }

    // MARK: - Properties
    var searchText = ""
    var selectedMuscle: MuscleGroup?
    var activeSheet: Sheet?
    var pendingDeletion: ExerciseDefinition?
    var errorMessage: String?
    private(set) var definitions: [ExerciseDefinition] = []
    private(set) var hasLoaded = false

    @ObservationIgnored private let libraryRepository: any UserExerciseLibraryRepositoryProtocol
    @ObservationIgnored weak var navigationManager: ExercisesNavigationManager?
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    /// Muscles that at least one exercise uses, for the filter bar.
    var availableMuscles: [MuscleGroup] {
        let used = Set(definitions.flatMap(\.primaryMuscles))
        return MuscleGroup.allCases.filter { used.contains($0) }
    }

    var sections: [ExerciseSection] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = definitions.filter { definition in
            let matchesQuery = query.isEmpty || definition.name.localizedStandardContains(query)
            let matchesMuscle = selectedMuscle.map { definition.primaryMuscles.contains($0) } ?? true
            return matchesQuery && matchesMuscle
        }

        if let selectedMuscle {
            guard !filtered.isEmpty else { return [] }
            return [ExerciseSection(id: selectedMuscle.rawValue, title: selectedMuscle.displayName, definitions: filtered)]
        }
        return ExerciseSection.grouped(filtered)
    }

    var isLibraryEmpty: Bool {
        hasLoaded && definitions.isEmpty
    }

    // MARK: - Initializers
    init(
        libraryRepository: any UserExerciseLibraryRepositoryProtocol,
        navigationManager: ExercisesNavigationManager
    ) {
        self.libraryRepository = libraryRepository
        self.navigationManager = navigationManager
        subscribeToLibrary()
    }

    // MARK: - Public Methods
    func load() async {
        do {
            try await libraryRepository.loadData()
        } catch {
            errorMessage = "Your exercises couldn't be loaded. Pull to try again."
        }
        hasLoaded = true
    }

    func handleNewExerciseTapped() {
        activeSheet = .create
    }

    func handleExerciseTapped(_ definition: ExerciseDefinition) {
        activeSheet = .edit(definition)
    }

    func handleDeleteTapped(_ definition: ExerciseDefinition) {
        pendingDeletion = definition
    }

    func confirmDeletion() {
        guard let definition = pendingDeletion else { return }
        pendingDeletion = nil
        Task {
            do {
                try await libraryRepository.delete(entity: definition)
            } catch {
                errorMessage = "\(definition.name) couldn't be deleted. Try again."
            }
        }
    }

    // MARK: - Private Methods
    private func subscribeToLibrary() {
        libraryRepository.entitiesPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] definitions in
                self?.definitions = definitions
            }
            .store(in: &cancellables)
    }
}
