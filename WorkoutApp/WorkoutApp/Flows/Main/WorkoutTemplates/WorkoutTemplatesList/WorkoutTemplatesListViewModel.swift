//
//  WorkoutTemplatesListViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 29.05.2023.
//

import SwiftUI

extension WorkoutTemplatesList {
   
    @Observable class ViewModel {
        
        //MARK: - Properties
        var workoutTemplates = [Workout]()
        var isLoading = false
        private let workoutTemplateService: any WorkoutServiceProtocol
        
        @ObservationIgnored weak var navigationManager: WorkoutTemplatesNavigationManager?
        
        private var loadTask: Task<Void, Never>?
        
        init(workoutTemplateService: any WorkoutServiceProtocol) {
            self.workoutTemplateService = workoutTemplateService
            loadTemplates()
        }
        
        //MARK: - Private Methods
        private func loadTemplates() {
            loadTask?.cancel()
            isLoading = true
            loadTask = Task { @MainActor [weak self] in
                guard let self = self else { return }
                do {
                    self.workoutTemplates = try await workoutTemplateService.getAll()
                } catch {
                    print("Error while loading templates: \(error.localizedDescription)")
                }
                self.isLoading = false
            }
        }
        
        //MARK: - Event handlers
        func handleAddButtonTapped() {
            navigationManager?.push(WorkoutTemplateBuilderRoute())
        }
        
        func handleTemplateTapped(_ template: Workout) {
            navigationManager?.push(WorkoutTemplateBuilderRoute(templateId: template.id))
        }
        
        func handleOnAppear() {
            loadTemplates()
        }
        
        @MainActor
        func refreshTemplates() async {
            loadTask?.cancel()
            isLoading = true
            do {
                workoutTemplates = try await workoutTemplateService.getAll()
            } catch {
                print("Error while refreshing templates: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
}

