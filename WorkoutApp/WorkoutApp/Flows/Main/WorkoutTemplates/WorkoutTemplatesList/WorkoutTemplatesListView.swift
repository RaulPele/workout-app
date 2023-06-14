//
//  WorkoutTemplatesListView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 29.05.2023.
//

import SwiftUI

struct WorkoutTemplatesList {
    
    struct ContentView: View {
        
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    titleView

                    ForEach(viewModel.workoutTemplates) { template in
                        WorkoutTemplateCardView(workoutTemplate: template)
                    }
                    .animation(.default, value: viewModel.workoutTemplates)

                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .onAppear {
                viewModel.handleOnAppear()
            }
            
        }
        
        private var titleView: some View {
            HStack {
                Text("Workout templates")
                    .foregroundColor(.onSurface)
                    .font(.heading1)
                Spacer()
                
                Button {
                    //TODO: navigate to template builder screen
                    viewModel.handleAddButtonTapped()
                } label: {
                    Image(systemName: "plus")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.primaryColor)
                }
                .buttonStyle(.plain)
                    
            }
        }
    }
}

#if DEBUG
struct WorkoutTemplatesListView_Previews: PreviewProvider {
    
    static var previews: some View {
        ForEach(previewDevices) { device in
            WorkoutTemplatesList.ContentView(viewModel: .init(workoutTemplateService: MockedWorkoutTemplateService()))
                .preview(device)
        }
    }
}
#endif
