//
//  DayPlanTemplateView.swift
//  iva_ios
//
//  Created by Igor Pidik on 08/05/2022.
//

import SwiftUI

struct DayPlanTemplateView: View {
    @State var template: DayPlanTemplate
    @Environment(\.editMode) private var editMode
    @Environment(\.presentationMode) var presentationMode
    @State private var showAddActionSheet = false
    @State private var editingActivity: DayPlanTemplateActivity?
    var onSave: ((DayPlanTemplate) -> Void)?
    private var creatingNewTemplate: Bool {
        return onSave != nil
    }
    
    var body: some View {
        VStack {
            if editMode?.wrappedValue.isEditing ?? false {
                TextField("Template name", text: $template.name).textFieldStyle(RoundedBorderTextFieldStyle()).padding()
            } else {
                Text(template.name)
            }
            List {
                ForEach(template.activities) { activity in
                    TemplateActivityView(activity: activity).contentShape(Rectangle())
                        .onTapGesture {
                            if editMode?.wrappedValue.isEditing ?? false {
                                editingActivity = activity
                            }
                        }
                }
                
            }
            if creatingNewTemplate {
                Button("Save") {
                    onSave?(template)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .onAppear(perform: {
            if creatingNewTemplate {
                editMode?.wrappedValue = .active
            }
        })
        .sheet(item: $editingActivity, onDismiss: {
            editMode?.wrappedValue = .inactive
        }, content: { activity in
            EditDayPlanActivity(activity: activity, addingActivity: false) { updatedActivity in
                let index = template.activities.firstIndex { checkingActivity in
                    return checkingActivity.id == updatedActivity.id
                }!
                template.activities[index] = updatedActivity
                editingActivity = nil
                if !creatingNewTemplate {
                    IvaBackendClient.patchDayPlanTemplateActivity(dayPlanTemplateId: template.id, activity: updatedActivity).catch { err in
                        print(err)
                    }
                }
            } onDeleteAction: { deletedActivity in
                let index = template.activities.firstIndex { checkingActivity in
                    return checkingActivity.id == deletedActivity.id
                }!
                template.activities.remove(at: index)
                editingActivity = nil
                if !creatingNewTemplate {
                    IvaBackendClient.deleteDayPlanTemplateActivity(dayPlanTemplateId: template.id, activity: deletedActivity).catch { err in
                        print(err)
                    }
                }
            }
        })
        .sheet(isPresented: $showAddActionSheet, content: {
            let activity = DayPlanTemplateActivity(
                id: -1, name: "", description: "",
                startTime: Date().toTimeString(), endTime: Date().toTimeString(),
                type: .other
            )
            
            EditDayPlanActivity(activity: activity, addingActivity: true) { newTemplateActivity in
                showAddActionSheet = false
                template.activities.append(newTemplateActivity)
                IvaBackendClient.postDayPlanTemplateActivity(dayPlanTemplateId: template.id, activity: newTemplateActivity).catch { err in
                    print(err)
                }
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
                if !creatingNewTemplate {
                    EditButton()
                }
            }
        }.navigationBarTitleDisplayMode(.inline).onChange(of: editMode?.wrappedValue) { value in
            if !(value?.isEditing ?? true) {
                IvaBackendClient.patchDayPlanTemplate(template: template).done { patchedTemplate in
                    template = patchedTemplate
                }.catch { err in
                    print(err)
                }
            }
        }
    }
}
