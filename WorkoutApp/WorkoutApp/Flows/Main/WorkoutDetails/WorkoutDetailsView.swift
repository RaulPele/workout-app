//
//  WorkoutDetailsView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 04.05.2023.
//

import SwiftUI


struct WorkoutDetails {
    
    struct ContentView: View {
        
        @ObservedObject var viewModel: ViewModel
        
        private let detailsColumns = [GridItem(.flexible()), GridItem(.flexible())]
        
        var body: some View {
            VStack {
                NavigationBar(
                    title: viewModel.workout.title,
                    backButtonAction: {
                        viewModel.onBack?()
                    }
                )
                .foregroundColor(.white)
                ScrollView {
                    workoutDetailsView
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal)
            }
            .background(Color.background)
        }
        
        private var titleView: some View {
            Text(viewModel.workout.title)
                .foregroundColor(Color.white)
                .font(.heading1)
        }
        
        private var workoutDetailsView: some View {
            VStack(alignment: .leading) {
                
                Text("Workout details")
                    .foregroundColor(.white)
                    .font(.heading2)
                
                ListView(items: viewModel.workoutDetailsData) { rowData in
                    rowView(for: rowData)
                }
                
            }
            
        }
        
        private var divider: some View {
            Rectangle()
                .foregroundColor(.white)
                .frame(height: 1)
                
                
        }
        
        private func rowView(for rowData: WorkoutDetails.RowData) -> some View {
            HStack {
                cellView(for: rowData.first)
                    .frame(maxWidth: .infinity, alignment: .leading)
                cellView(for: rowData.second)
                    .frame(maxWidth: .infinity, alignment: .leading)

            }
        }
        
        private func cellView(for characteristic: WorkoutCharacteristic) -> some View {
            
            VStack(alignment: .leading) {
                Text(characteristic.key.title)
                Text(characteristic.displayValue)
            }
            .foregroundColor(foregroundColor(for: characteristic))
        }
        
        private func foregroundColor(for characteristic: WorkoutCharacteristic) -> Color {
            switch characteristic.key {
            case .totalCalories, .activeCalories:
                return .mint
            case .duration:
                return .green
            
            case .avgHeartRate:
                return .red
                
            default:
                return .white
            }
        }
        
    }
    
    
}

#if DEBUG
struct WorkoutDetailsView_Previews: PreviewProvider {
    
    private static let viewModel = WorkoutDetails.ViewModel(workout: .mocked2)
    
    static var previews: some View {
        
        ForEach(previewDevices) { device in
            WorkoutDetails.ContentView(viewModel: viewModel)
                .preview(device)
        }
    }
}
#endif
