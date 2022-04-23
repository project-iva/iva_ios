//
//  DayPlanning.swift
//  iva_ios
//
//  Created by Igor Pidik on 23/04/2022.
//

import SwiftUI

struct DayPlanning: View {
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
            DayPlanningView(dayDate: dayDate)
        }
        .navigationBarTitle("", displayMode: .inline)
    }
}

struct DayPlanning_Previews: PreviewProvider {
    static var previews: some View {
        DayPlanning()
    }
}
