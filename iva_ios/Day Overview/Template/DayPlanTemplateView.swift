//
//  DayPlanTemplateView.swift
//  iva_ios
//
//  Created by Igor Pidik on 08/05/2022.
//

import SwiftUI

struct DayPlanTemplateView: View {
    @State var template: DayPlanTemplate
    @State private var showAddActionSheet = false
    var body: some View {
        VStack {
            Text(template.name)
            List {
                ForEach(template.activities) { activity in
                    TemplateActivityView(activity: activity)
                }.onDelete { offset in
                    
                }
                
            }
        }
        .sheet(isPresented: $showAddActionSheet, content: {
            let activity = DayPlanTemplateActivity(
                id: -1, name: "", description: "",
                startTime: Date().toTimeString(), endTime: Date().toTimeString(),
                type: .other
            )
            
            EditDayPlanActivity(activity: activity, addingActivity: true) { newTemplateActivity in
                showAddActionSheet = false
                template.activities.append(newTemplateActivity)
            }
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddActionSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }.navigationBarTitleDisplayMode(.inline)
    }
}
