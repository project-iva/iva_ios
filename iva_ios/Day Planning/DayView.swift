//
//  DayView.swift
//  iva_ios
//
//  Created by Igor Pidik on 09/08/2021.
//

import SwiftUI

enum DaySegment: String, CaseIterable {
    case dayPlan = "Day Plan"
    case dayGoals = "Day Goals"
}

struct DayView: View {
    @State private var daySegment: DaySegment = .dayPlan
    
    var body: some View {
        VStack {
            Picker("Day", selection: $daySegment) {
                ForEach(DaySegment.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }.pickerStyle(SegmentedPickerStyle())
            .padding()
            
            switch daySegment {
                case .dayPlan:
                    DayPlanView()
                case .dayGoals:
                    DayGoalsView()
            }
        }
    }
}

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        DayView()
    }
}
