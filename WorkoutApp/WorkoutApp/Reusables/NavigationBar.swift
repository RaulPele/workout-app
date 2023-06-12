//
//  NavigationBar.swift
//  WorkoutApp
//
//  Created by Raul Pele on 06.05.2023.
//

import SwiftUI

struct NavigationBar<RightView: View>: View {
    
    let title: String
    
    let backButtonAction: (() -> Void)?
    @ViewBuilder let rightView: () -> RightView
    
    
    init(title: String,
         backButtonAction: (() -> Void)? = nil,
         @ViewBuilder rightView: (@escaping () -> RightView) = { EmptyView()}) {
        self.title = title
        self.backButtonAction = backButtonAction
        self.rightView = rightView
    }
    
    var showBackButton: Bool {
        return backButtonAction != nil
    }
    
    var body: some View {
        HStack {
            if showBackButton {
                backButtonView
            }
            
            Spacer()
            
            titleView
            Spacer()
        }
        .overlay(rightView(), alignment: .trailing)
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .foregroundColor(.onBackground)
    }
    
    private var backButtonView: some View {
        Button {
            backButtonAction?()
        } label: {
            Image(systemName: "chevron.left")
                .renderingMode(.template)
        }
        .buttonStyle(.plain)
    }
    
    private var titleView: some View {
        Text("\(title)")
            
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            NavigationBar(title: "Morning session", backButtonAction:  {
                
            })
        }
        
    }
}
