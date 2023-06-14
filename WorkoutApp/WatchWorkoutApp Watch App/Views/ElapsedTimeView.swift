//
//  ElapsedTimeView.swift
//  WatchWorkoutApp Watch App
//
//  Created by Raul Pele on 11.05.2023.
//

import SwiftUI

struct ElapsedTimeView: View {
    
    var elapsedTime: TimeInterval = 0
    var showSubseconds: Bool = true
    
    @State private var timeFormatter: ElapsedTimeFormatter
    
    init(elapsedTime: TimeInterval = 0, showSubseconds: Bool = true) {
        self.elapsedTime = elapsedTime
        self.showSubseconds = showSubseconds
        _timeFormatter = State(wrappedValue: ElapsedTimeFormatter(showSubseconds: showSubseconds))
    }

    var body: some View {
        Text(NSNumber(value: elapsedTime), formatter: timeFormatter)
            .fontWeight(.semibold)
            .onChange(of: showSubseconds) {
                timeFormatter.showSubseconds = $0
            }
    }
}

class ElapsedTimeFormatter: Formatter {
    
    let componentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    var showSubseconds = true
    
    init(showSubseconds: Bool = true) {
        super.init()
        self.showSubseconds = showSubseconds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func string(for value: Any?) -> String? {
        guard let time = value as? TimeInterval else {
            return nil
        }

        guard let formattedString = componentsFormatter.string(from: time) else {
            return nil
        }

        if showSubseconds {
            let hundredths = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
            let decimalSeparator = Locale.current.decimalSeparator ?? "."
            return String(format: "%@%@%0.2d", formattedString, decimalSeparator, hundredths)
        }

        return formattedString
    }
}

//struct ElapsedTimeView_Previews: PreviewProvider {
//    static var previews: some View {
//        ElapsedTimeView()
//    }
//}
