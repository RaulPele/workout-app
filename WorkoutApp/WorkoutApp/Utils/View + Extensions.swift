//
//  View + Extensions.swift
//  WorkoutApp
//
//  Created by Raul Pele on 02.05.2023.
//

import Foundation
import SwiftUI

extension View {
    
    func preview(_ device: PreviewDevice) -> some View {
        self
            .previewDevice(device)
            .previewDisplayName(device.rawValue)
    }
}
