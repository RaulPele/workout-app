//
//  WelcomeView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 13.06.2023.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            Text("Welcome! ")
                .font(.heading1)
                .foregroundColor(Color.onBackground)
            
//
            Text("WorkoutApp is an easy way to track and analyze your workout sessions")
                .font(.heading1)
                .foregroundColor(.onBackground)
                .multilineTextAlignment(.center)
            Spacer()
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.background)
        
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
