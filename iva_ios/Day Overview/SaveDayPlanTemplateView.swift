//
//  SaveDayPlanTemplateView.swift
//  iva_ios
//
//  Created by Igor Pidik on 07/05/2022.
//

import SwiftUI

struct SaveDayPlanTemplateView: View {
    @State var template: DayPlanTemplate
    let onSave: (DayPlanTemplate) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Text("Save template").font(.title)
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
