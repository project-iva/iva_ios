//
//  EditDayPlanActivity.swift
//  iva_ios
//
//  Created by Igor Pidik on 14/08/2021.
//

import SwiftUI

struct EditDayPlanActivity<T: Activity>: View {
    @State var activity: T
    @State var addingActivity: Bool
    var onSaveAction: ((T) -> Void)
    var onDeleteAction: ((T) -> Void)?
    
    var body: some View {
        VStack {
            if addingActivity {
                Text("Create Activity").font(.title)
            } else {
                Text("Edit Activity").font(.title)
            }
            TextField("Activity name", text: $activity.name).textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Description", text: $activity.description).textFieldStyle(RoundedBorderTextFieldStyle())
            DatePicker("Start time", selection: Binding(
                get: { activity.startTime.toDateTime()},
                set: { activity.startTime = $0.toTimeString() }
            ), displayedComponents: .hourAndMinute)
            DatePicker("End time", selection: Binding(
                get: { activity.endTime.toDateTime()},
                set: { activity.endTime = $0.toTimeString() }
            ), displayedComponents: .hourAndMinute)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Activity type")
                Picker("Type", selection: $activity.type) {
                    ForEach(DayPlanActivityType.allCases, id: \.self) {
                        Text($0.displayName)
                    }
                }.pickerStyle(WheelPickerStyle())
            }
            
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
