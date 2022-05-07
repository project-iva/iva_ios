//
//  SelectActivitiesFromTemplate.swift
//  iva_ios
//
//  Created by Igor Pidik on 07/05/2022.
//

import SwiftUI

struct SelectActivitiesFromTemplate: View {
    @State var activities: [DayPlanTemplateActivity] = []
    var onDone: ([DayPlanTemplateActivity]) -> Void
    @State private var selection = Set<DayPlanTemplateActivity>()
    
    var body: some View {
        VStack {
            List(activities) { activity in
                let activityView = TemplateActivityView(activity: activity).contentShape(Rectangle())
                if selection.contains(activity) {
                    activityView.onTapGesture {
                        selection.remove(activity)
                    }
                } else {
                    activityView.onTapGesture {
                        selection.insert(activity)
                    }.opacity(0.2)
                }
            }
            
            Button("Done") {
                onDone(Array(selection))
            }.padding()
            
        }.navigationTitle("Select activities").navigationBarTitleDisplayMode(.inline).toolbar {
            if selection.isEmpty {
                Button("Select all") {
                    selection = Set(activities)
                }
            } else {
                Button("Deselect all") {
                    selection.removeAll()
                }
            }
        }
    }
}
