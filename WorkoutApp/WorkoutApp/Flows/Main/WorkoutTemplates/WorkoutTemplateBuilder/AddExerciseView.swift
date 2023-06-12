//
//  AddExerciseView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.06.2023.
//

import SwiftUI

struct AddExerciseView: View {
    
    let existentExercises: [Exercise] = [.mockedBBBenchPress, .mockedBBSquats]
    @State private var newExerciseName: String = ""
    @State private var isAddingExercise = false
    
    var body: some View {
        VStack {
            ForEach(existentExercises) { exercise  in
                Button {
                    print("Exercise tapped")
                } label: {
                    Text(exercise.name)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                }
                
                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(height: 1)
                    .padding(.horizontal, 24)
            }

            Button {
                isAddingExercise = true
            } label: {
                Text("Add exercise...")
                    .padding(10)
            }
                
        }
        .padding()
        .background(Color.surface2)
        .overlay {
            if isAddingExercise {
                ZStack {
                    Color.surface2
                    
                    VStack(spacing: 15) {
                        FloatingTextField(title: "Name", text: $newExerciseName)
                            .padding(.horizontal, 20)
                        HStack(spacing: 40) {
                            
                            Button(role: .cancel) {
                                isAddingExercise = false
                            } label: {
                                Text("Cancel")
                            }
                            .padding()
                            .frame(width: 120)

                            Buttons.Filled(title: "Add") {
                                
                            }
                            .frame(width: 120)
                            
                        }
                    }
                    .padding()
                }
                .transition(.opacity.animation(.easeInOut))

            }
        }
        .cornerRadius(15)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
struct AddExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExerciseView()
    }
}
