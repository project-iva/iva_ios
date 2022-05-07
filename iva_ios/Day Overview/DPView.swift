//
//  DPView.swift
//  iva_ios
//
//  Created by Igor Pidik on 06/05/2022.
//

import SwiftUI

struct DPView: View {
    @State private var dayPlanTemplates = [DayPlanTemplate]()
    var onDone: ([DayPlanTemplateActivity]) -> Void
    
    var body: some View {
        NavigationView {
            List(dayPlanTemplates) { template in
                NavigationLink(destination: SelectActivitiesFromTemplate(activities: template.activities, onDone: onDone)) {
                    Text(template.name)
                }
            }.navigationTitle("Select template").navigationBarTitleDisplayMode(.inline)
        }.onAppear(perform: loadTemplates)
        
    }
    
    private func loadTemplates() {
        IvaBackendClient.fetchDayPlanTemplates().done { result in
            dayPlanTemplates = result
        }.catch { error in
            print(error)
        }
    }
}
