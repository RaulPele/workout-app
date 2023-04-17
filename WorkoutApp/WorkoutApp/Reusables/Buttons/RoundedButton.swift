//
//  RoundedButton.swift
//  WorkoutApp
//
//  Created by Raul Pele on 01.04.2023.
//

import SwiftUI


struct Buttons {
    
    struct Filled: View {
        
        let title: String
        var backgroundColor: Color = .blue
        var foregroundColor: Color = .white
        var fontSize: CGFloat = 15
        var onAction: () -> Void
        
        
        var body: some View {
            Button {
                onAction()
            } label: {
                Text(title)
            }
            .buttonStyle(ButtonStyles.Filled(foregroundColor: foregroundColor, backgroundColor: backgroundColor, fontSize: 15))
        }
    }
}

struct RoundedButton_Previews: PreviewProvider {
    static var previews: some View {
        Buttons.Filled(title: "Hello") {
            
        }
    }
}
