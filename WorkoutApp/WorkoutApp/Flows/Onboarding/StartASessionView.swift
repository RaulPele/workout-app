//
//  StartASessionView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 13.06.2023.
//

import SwiftUI

struct StartASessionView: View {
    var body: some View {
        VStack(spacing: 60) {
            Spacer()
            Text("Start a workout session from your watch! ")
                .font(.heading1)
                .foregroundColor(Color.onBackground)
                .multilineTextAlignment(.center)
            
//
            Image("watch-list-view")
                .cornerRadius(15)
                .shadow(color: .white, radius: 8)
            Spacer()
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.background)
    }
}

struct StartASessionView_Previews: PreviewProvider {
    static var previews: some View {
        StartASessionView()
    }
}
