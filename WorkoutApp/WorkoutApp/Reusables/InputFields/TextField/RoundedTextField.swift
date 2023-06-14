//
//  RoundedTextField.swift
//  WorkoutApp
//
//  Created by Raul Pele on 08.04.2023.
//

import SwiftUI

struct RoundedTextField: View {
    
    @Binding private var text: String
    
    private var placeHolderText: String?
    private var foregroundColor: Color
    private var backgroundColor: Color
    private var borderColor: Color
    private var isSecured: Bool
    private var keyboardType: UIKeyboardType = .default
    private var textContentType: UITextContentType?
    
    init(text: Binding<String>,
         placeHolderText: String = "Enter text here",
         isSecured: Bool = false,
         foregroundColor: Color = .black,
         backgroundColor: Color = .white,
         borderColor: Color = .mint,
         keyboardType: UIKeyboardType = .default,
         textContentType: UITextContentType? = nil) {
        self._text = text
        self.placeHolderText = placeHolderText
        self.isSecured = isSecured
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.borderColor = borderColor
        self.keyboardType = keyboardType
        self.textContentType = textContentType
    }
    
    var body: some View {
        inputView(isSecured: isSecured)
            .padding(14)
            .background(backgroundColor.cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(borderColor, lineWidth: 1.5)))
            .foregroundColor(foregroundColor)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .textContentType(textContentType)
            .keyboardType(keyboardType)
            
            
    }
    
    @ViewBuilder
    private func inputView(isSecured: Bool) -> some View {
        if isSecured {
            SecureField(placeHolderText ?? "", text: $text)
        } else {
            TextField(placeHolderText ?? "", text: $text)
        }
    }
}

#if DEBUG
struct RoundedTextField_Previews: PreviewProvider {
    
    struct TextFieldPreiews: View {
        
        @State var text: String = ""
        @State var securedText: String = ""
        
        var body: some View {
            VStack(spacing: 20) {
                RoundedTextField(text: $text)
                RoundedTextField(text: $securedText, isSecured: true)
            }
        }
    }
    
    static var previews: some View {
        ForEach(previewDevices) { device in
            TextFieldPreiews()
                .previewDevice(device)
                .previewDisplayName(device.rawValue)
        }
    }
}
#endif
