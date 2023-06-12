//
//  FloatingTextField.swift
//  WorkoutApp
//
//  Created by Raul Pele on 31.05.2023.
//

import SwiftUI

struct FloatingTextField: View {
    
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ZStack(alignment: .leading) {
                    Text(title)
                        .foregroundColor(.white.opacity(0.8))
                        .font(.body)
                        .offset(y: text.isEmpty ? 0 : -25)
                        .padding(.vertical, 10)
                    
                    TextField("", text: $text)
                        .foregroundColor(.white.opacity(0.8))
                        .disableAutocorrection(true)
                        .font(.body)
                        .focused($isFocused)
                        .textInputAutocapitalization(.never)
                        .keyboardType(keyboardType)
                    
                }
                .animation(.spring(response: 0.2, dampingFraction: 0.5), value: text)
            }
            
            Divider()
                .frame(height: isFocused ? 2 : 1)
                .background(isFocused ? Color.white : Color.gray)
                .padding(.top, 6)
        }
    }
}

#if DEBUG
struct FloatingTextField_Previews: PreviewProvider {
    
    struct TestView: View {
        
        @State var text: String = ""
        
        var body: some View {
            FloatingTextField(title: "Title", text: $text)
        }
    }
    
    static var previews: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack {
                TestView()
                TestView()
            }
        }
    }
}
#endif
