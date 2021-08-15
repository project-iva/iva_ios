//
//  EditDayPlanActivity.swift
//  iva_ios
//
//  Created by Igor Pidik on 14/08/2021.
//

import SwiftUI

struct EditDayPlanActivity: View {
    @State var activity: DayPlanActivity
    @State var addingActivity: Bool
    var onSaveAction: ((DayPlanActivity) -> Void)
    var onDeleteAction: ((DayPlanActivity) -> Void)?
    
    var body: some View {
        VStack {
            if addingActivity {
                Text("Create Activity")
            } else {
                Text("Edit Activity")
            }
            TextField("Activity name", text: $activity.name).textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Description", text: $activity.description).textFieldStyle(RoundedBorderTextFieldStyle())
            DatePicker("Start time", selection: Binding(
                get: { activity.startTime.toDateTime()!},
                set: { activity.startTime = $0.toTimeString() }
            ), displayedComponents: .hourAndMinute)
            DatePicker("End time", selection: Binding(
                get: { activity.endTime.toDateTime()!},
                set: { activity.endTime = $0.toTimeString() }
            ), displayedComponents: .hourAndMinute)
            Spacer()
            HStack {
                if !addingActivity {
                    Button("Delete") {
                        onDeleteAction?(activity)
                    }.foregroundColor(.red)
                    
                    Spacer()
                }
                
                Button("Save") {
                    onSaveAction(activity)
                }
            }
        }.padding()
    }
}
