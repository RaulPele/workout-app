//
// LoginViewModel.swift
// WorkoutApp
//
// Created by Raul Pele on 08.04.2023.
//
//

import Foundation

extension Login {
    
    class ViewModel: ObservableObject {
        
        @Published var isLoading: Bool = false
        @Published var email: String = ""
    }
}
