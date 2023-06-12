//
//  ExerciseView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 31.05.2023.
//

import Foundation
import SwiftUI

struct ExerciseView: View {
    
    var exercise: Exercise
    @State var isExpanded: Bool = false
    let onEditAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(exercise.name)
                    .font(.heading3)
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .bold()
            }

            if isExpanded {
                Rectangle()
                    .frame(height: 1)
                    
                HStack(spacing: 20) {
                    HStack {
                        exerciseMetricView(
                            title: "Sets",
                            value: exercise.numberOfSets) {
                                onEditAction()
                            }
                        
                        exerciseMetricView(
                            title: "Reps",
                            value: exercise.setData.reps) {
                                onEditAction()
                            }
                    }
                    
                    VStack(spacing: 5) {
                        Text("Rest time / set")
                        HStack {
                            Button {
                                onEditAction()
                            } label: {
                                Text(String(Int(exercise.restBetweenSets / 60).formatted(.number)))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.cornerRadius(15))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 15)
                                            .strokeBorder(.gray, lineWidth: 4)
                                    }
                            }
                            .buttonStyle(.plain)
                         
                            Button {
                                onEditAction()
                            } label: {
                                Text(String((exercise.restBetweenSets.truncatingRemainder(dividingBy: 60)).formatted(.number)))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.cornerRadius(15))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 15)
                                            .strokeBorder(.gray, lineWidth: 4)
                                    }
                                    .lineLimit(1)
                            }
                            .buttonStyle(.plain)
                        }
                    }.frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primaryColor)
        .cornerRadius(10)
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
    
    private func exerciseMetricView(
        title: String,
        value: Int,
        onTapGesture: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 5) {
            Text(title)
            Button {
                onTapGesture()
            } label: {
                Text(String(value))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.background.cornerRadius(15))
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .strokeBorder(Color.gray, lineWidth: 4)
                    }
            }
            .buttonStyle(.plain)
        }
    }
}
