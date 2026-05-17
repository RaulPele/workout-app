//
//  WorkoutAppApp.swift
//  WorkoutApp
//
//  Created by Raul Pele on 25.03.2023.
//

import FirebaseCore
import SwiftUI

@main
struct WorkoutAppApp: App {

    @State private var dependencyContainer: any DependencyContainerProtocol

    init() {
        FirebaseApp.configure()
        _dependencyContainer = State(initialValue: DependencyContainer.live())
    }

    var body: some Scene {
        WindowGroup {
            RootCoordinatorView()
                .environment(\.dependencyContainer, dependencyContainer)
        }
    }
}

