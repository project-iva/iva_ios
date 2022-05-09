//
//  DayPlanTemplateView.swift
//  iva_ios
//
//  Created by Igor Pidik on 08/05/2022.
//

import SwiftUI

struct DayPlanTemplatesView: View {
    @Environment(\.editMode) var editMode
    @State var templates: [DayPlanTemplate] = []
    @State var detailedTemplate: DayPlanTemplate?
    @State var editingTemplate: DayPlanTemplate?
    
    var body: some View {
        List(templates) { template in
            NavigationLink(destination: DayPlanTemplateView(template: template)) {
                Text(template.name)
            }
        }
        .onAppear(perform: loadTemplates)
        .navigationTitle("Templates")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    //                    showAddActionSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $detailedTemplate) { template in
            Text(template.name)
        }.sheet(item: $editingTemplate, onDismiss: {
            editMode?.wrappedValue = .inactive
        }) { template in
            EditDayPlanTemplateView(template: template) { editedTemplate in
                
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
