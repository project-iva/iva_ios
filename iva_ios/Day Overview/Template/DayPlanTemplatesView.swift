//
//  DayPlanTemplateView.swift
//  iva_ios
//
//  Created by Igor Pidik on 08/05/2022.
//

import SwiftUI

struct DayPlanTemplatesView: View {
    @StateObject private var model = DayPlanTemplatesModel()
    @State private var showAddTemplate = false
    private let newTemplate = DayPlanTemplate(id: -1, name: "", activities: [])
    
    var body: some View {
        List(model.templates) { template in
            NavigationLink(destination: DayPlanTemplateView(model: model, template: template)) {
                Text(template.name)
            }
        }
        .background(
            NavigationLink(
                destination: DayPlanTemplateView(model: model, template: newTemplate, onSave: model.saveTemplate),
                isActive: $showAddTemplate
            ) {
                EmptyView()
            }.hidden()
        )
        .navigationTitle("Templates")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddTemplate = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}
