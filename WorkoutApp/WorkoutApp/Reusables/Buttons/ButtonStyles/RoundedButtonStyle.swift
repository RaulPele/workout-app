//
//  RoundedButtonStyle.swift
//  WorkoutApp
//
//  Created by Raul Pele on 01.04.2023.
//

import Foundation
import SwiftUI

struct ButtonStyles {
    
    struct Filled: ButtonStyle {
        
        let foregroundColor: Color
        let backgroundColor: Color
        let fontSize: CGFloat
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .foregroundColor(foregroundColor)
                .font(.system(size: fontSize))
                .padding()
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .cornerRadius(15)
                .opacity(configuration.isPressed ? 0.8 : 1)
        }
    }
}
