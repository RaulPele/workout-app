//
//  WorkoutTemplatesListViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 29.05.2023.
//

import SwiftUI

extension WorkoutTemplatesList {
   
    class ViewModel: ObservableObject {
        
        //MARK: - Properties
        @Published var workoutTemplates = [WorkoutTemplate]()
        private let workoutTemplateService: any WorkoutTemplateServiceProtocol
        
        weak var navigationManager: WorkoutTemplatesNavigationManager?
        
        var loadTask: Task<Void, Never>?
        
        init(workoutTemplateService: any WorkoutTemplateServiceProtocol) {
            self.workoutTemplateService = workoutTemplateService
            loadTemplates()
        }
        
        //MARK: - Private Methods
        private func loadTemplates() {
            loadTask?.cancel()
            loadTask = Task { @MainActor [weak self] in
                guard let self = self else { return }
                do {
                    self.workoutTemplates = try await workoutTemplateService.getAll()
                } catch {
                    print("Error while loading templates: \(error.localizedDescription)")
                }
            }
        }
        
        //MARK: - Event handlers
        func handleAddButtonTapped() {
            navigationManager?.push(WorkoutTemplateBuilderRoute())
        }
        
        func handleOnAppear() {
            loadTemplates()
        }
        
        
    }
}

