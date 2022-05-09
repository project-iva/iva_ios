//
//  SaveDayPlanTemplateView.swift
//  iva_ios
//
//  Created by Igor Pidik on 07/05/2022.
//

import SwiftUI

struct EditDayPlanTemplateView: View {
    @State var template: DayPlanTemplate
    let creatingTemplate = false
    let onSave: (DayPlanTemplate) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                if creatingTemplate {
                    Text("Save template").font(.title)
                } else {
                    Text("Edit template").font(.title)
                }
                TextField("Template name", text: $template.name).textFieldStyle(RoundedBorderTextFieldStyle())
            }.padding().padding(.bottom, 0)
            List(template.activities) { activity in
                TemplateActivityView(activity: activity)
            }
            Spacer()
            Button("Save") {
                onSave(template)
            }.padding()
        }
    }
}
