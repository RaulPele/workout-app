//
//  WorkoutAppApp.swift
//  WorkoutApp
//
//  Created by Raul Pele on 25.03.2023.
//

import SwiftUI

@main
struct WorkoutAppApp: App {

    @State private var dependencyContainer: any DependencyContainerProtocol = DependencyContainer.live()

    var body: some Scene {
        WindowGroup {
            RootCoordinatorView(dependencyContainer: dependencyContainer)
        }
    }
}

