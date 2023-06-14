//
//  BuildTemplatesView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 13.06.2023.
//

import SwiftUI

struct BuildTemplatesView: View {
    var body: some View {
        VStack(spacing: 60) {
            Spacer()
            Text("Define your own workouts!")
                .font(.heading1)
                .foregroundColor(Color.onBackground)
                .multilineTextAlignment(.center)
            
                Image("template-builder-view")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(15)
                    .shadow(color: .white, radius: 8)
                    .frame(maxWidth: 250)
            Spacer()
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.bottom, 20)
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.background)    }
}

struct BuildTemplatesView_Previews: PreviewProvider {
    static var previews: some View {
        BuildTemplatesView()
    }
}
