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
        var backgroundColor: Color = .primaryColor
        var foregroundColor: Color = .onPrimary
        var fontSize: CGFloat = 15
        var isLoading: Bool = false
        var onAction: () -> Void
        
        
        var body: some View {
            Button {
                onAction()
            } label: {
                Text(title)
                    .opacity(isLoading ? 0 : 1)
                    
            }
            .buttonStyle(ButtonStyles.Filled(foregroundColor: foregroundColor, backgroundColor: backgroundColor, fontSize: fontSize))
            .disabled(isLoading)
            .overlay(loadingView, alignment: .center)
        }
        
        @ViewBuilder
        private var loadingView: some View {
            if isLoading {
                ActivityIndicator(color: .white)
            }
        }
    }
}

struct RoundedButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Buttons.Filled(title: "Hello") {
                
            }
            
            Buttons.Filled(title: "Hello", isLoading: true) {
                
            }
        }
    }
}
