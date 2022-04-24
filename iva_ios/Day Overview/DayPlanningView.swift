//
//  DayPlanningView.swift
//  iva_ios
//
//  Created by Igor Pidik on 23/04/2022.
//

import SwiftUI

struct DayPlanningView: View {
    var dayDate: Date
    @State private var activities: [DayPlanActivity] = []
    @State private var dayPlanId: Int = 0
    @Environment(\.editMode) var editMode
    @State private var editingActivity: DayPlanActivity?
    @State private var showAddActivitySheet = false
    @State private var showAddActivitiesFromTemplateSheet = false
    @State private var showAddActionSheet = false
    
    var body: some View {
        List(activities) { activity in
            ActivityView(activity: activity).padding(.top, 8).contentShape(Rectangle())
                .onTapGesture {
                    if editMode?.wrappedValue.isEditing ?? false {
                        editingActivity = activity
                    }
                }
            
        }
        .onChange(of: dayDate) { newDate in
            fetchDayPlan(for: newDate)
        }
        .onAppear {
            fetchDayPlan(for: dayDate)
        }
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
        }
        .sheet(item: $editingActivity, onDismiss: {
            editMode?.wrappedValue = .inactive
        }, content: { activity in
            EditDayPlanActivity(activity: activity, addingActivity: false) { updatedActivity in
                let index = activities.firstIndex { checkingActivity in
                    return checkingActivity.id == updatedActivity.id
                }!
                activities[index] = updatedActivity
                editingActivity = nil
                
                IvaBackendClient.patchDayPlanActivity(dayPlanId: dayPlanId, activity: updatedActivity).catch { error in
                    print(updatedActivity)
                    print("Error updating day plan activity: \(error)")
                }
            } onDeleteAction: { deletedActivity in
                let index = activities.firstIndex { checkingActivity in
                    return checkingActivity.id == deletedActivity.id
                }!
                activities.remove(at: index)
                editingActivity = nil
                IvaBackendClient.deleteDayPlanActivity(dayPlanId: dayPlanId, activity: deletedActivity).catch { error in
                    print("Error deleting activity: \(error)")
                }
            }
        })
        .sheet(isPresented: $showAddActivitySheet) {
            let activity = DayPlanActivity(
                id: -1, name: "", description: "",
                startTime: Date().toTimeString(), endTime: Date().toTimeString(),
                type: .other
            )
            EditDayPlanActivity(activity: activity, addingActivity: true) { newActivity in
                showAddActivitySheet = false
                IvaBackendClient.postDayPlanActivity(dayPlanId: dayPlanId, activity: newActivity)
                    .done { responseActivity in
                        activities.append(responseActivity)
                    }.catch { error in
                        print("Error adding day plan activity: \(error)")
                    }
            }
        }
        .sheet(isPresented: $showAddActivitiesFromTemplateSheet, content: {
            SelectTemplateView { template in
                showAddActivitiesFromTemplateSheet = false
                IvaBackendClient.addActivitiesFromDayPlanTemplate(dayPlanId: dayPlanId, dayPlanTemplateId: template.id)
                    .done { updatedDayPlan in
                        activities = updatedDayPlan.activities
                    }.catch { error in
                        print(error)
                    }
                
            }
        })
        .actionSheet(isPresented: $showAddActionSheet) {
            ActionSheet(title: Text("Add activities"), buttons: [
                .default(Text("Add an activity")) { showAddActivitySheet = true },
                .default(Text("Add activities from template")) { showAddActivitiesFromTemplateSheet = true },
                .cancel()
            ])
        }
    }
    
    private func fetchDayPlan(for date: Date) {
        IvaBackendClient.fetchDayPlan(for: date).done { dayPlan in
            activities = dayPlan.activities
            dayPlanId = dayPlan.id
        }.catch { error in
            print(error)
        }
    }
}
