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
    @State private var dayDate = Date()
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    dayDate = Calendar.current.date(byAdding: .day, value: -1, to: dayDate)!
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                DatePicker("Date", selection: $dayDate, displayedComponents: [.date])
                    .labelsHidden()
                    .id(dayDate)
                
                Button {
                    dayDate = Calendar.current.date(byAdding: .day, value: 1, to: dayDate)!
                } label: {
                    Image(systemName: "chevron.right")
                }
                Spacer()
            }
            
            Picker("Day", selection: $daySegment) {
                ForEach(DaySegment.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }.pickerStyle(SegmentedPickerStyle())
            .padding()
            
            switch daySegment {
                case .dayPlan:
                    DayPlanView(dayDate: dayDate)
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
