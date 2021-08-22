//
//  SelectTemplateView.swift
//  iva_ios
//
//  Created by Igor Pidik on 22/08/2021.
//

import SwiftUI

struct SelectTemplateView: View {
    let onTemplateSelected: (DayPlanTemplate) -> Void
    @State private var dayPlanTemplates = [DayPlanTemplate]()
    
    var body: some View {
        VStack {
            Text("Choose a day plan template").font(.title)
            List(dayPlanTemplates, id: \.id) { template in
                Button(template.name) {
                    selected(template: template)
                }
            }.onAppear(perform: loadTemplates)
            
        }.padding()
    }
    
    private func loadTemplates() {
        IvaBackendClient.fetchDayPlanTemplates().done { result in
            dayPlanTemplates = result
        }.catch { error in
            print(error)
        }
    }
    
    private func selected(template: DayPlanTemplate) {
        onTemplateSelected(template)
    }
}
