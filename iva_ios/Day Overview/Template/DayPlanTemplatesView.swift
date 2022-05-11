//
//  DayPlanTemplateView.swift
//  iva_ios
//
//  Created by Igor Pidik on 08/05/2022.
//

import SwiftUI

struct DayPlanTemplatesView: View {
    @State var templates: [DayPlanTemplate] = []
    @State private var showAddTemplate = false
    private let newTemplate = DayPlanTemplate(id: -1, name: "", activities: [])
    
    var body: some View {
        List(templates) { template in
            NavigationLink(destination: DayPlanTemplateView(template: template)) {
                Text(template.name)
            }
        }
        .background(
            NavigationLink(
                destination: DayPlanTemplateView(template: newTemplate, onSave: { createdTemplate in
                    IvaBackendClient.postDayPlanTemplate(template: createdTemplate).done { _ in
                       loadTemplates()
                    }.catch { err in
                        print(err)
                    }
                }),
                isActive: $showAddTemplate
            ) {
                EmptyView()
            }.hidden()
        )
        .onAppear(perform: loadTemplates)
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
    
    private func loadTemplates() {
        IvaBackendClient.fetchDayPlanTemplates().done { result in
            templates = result
        }.catch { error in
            print(error)
        }
    }
}
