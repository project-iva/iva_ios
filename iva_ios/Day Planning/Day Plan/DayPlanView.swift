//
//  DayPlanView.swift
//  iva_ios
//
//  Created by Igor Pidik on 09/08/2021.
//

import SwiftUI

struct DayPlanView: View {
    var dayDate: Date
    @State private var activities: [DayPlanActivity] = []
    @State private var dayPlanId: Int = 0
    @Environment(\.editMode) var editMode
    @State var editingActivity: DayPlanActivity?
    @State var addingActivity = false
    
    var body: some View {
        DayTimelineView(activities: $activities, delegate: DayTimelineView.Delegate(didTap: { activityEvent in
            print("tapped")
            if editMode?.wrappedValue.isEditing ?? false,
               let index = activities.firstIndex(where: { $0.id == activityEvent.activity.id }) {
                editingActivity = activities[index]
            }
        }))
        .onChange(of: dayDate, perform: { newDayDate in
            fetchDayPlan(for: newDayDate)
        })
        .onAppear(perform: {
            fetchDayPlan(for: dayDate)
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    addingActivity = true
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
        .sheet(isPresented: $addingActivity) {
            let activity = DayPlanActivity(
                id: -1, name: "", description: "", startTime: Date().toTimeString(), endTime: Date().toTimeString()
            )
            EditDayPlanActivity(activity: activity, addingActivity: true) { newActivity in
                addingActivity = false
                IvaBackendClient.postDayPlanActivity(dayPlanId: dayPlanId, activity: newActivity)
                    .done { responseActivity in
                        activities.append(responseActivity)
                    }.catch { error in
                        print("Error adding day plan activity: \(error)")
                    }
            }
        }
    }
    
    private func fetchDayPlan(for date: Date) {
        IvaBackendClient.fetchCurrentDayPlan().done { dayPlan in
            activities = dayPlan.activities
            dayPlanId = dayPlan.id
        }.catch { error in
            print(error)
        }
    }
}

struct DayPlanView_Previews: PreviewProvider {
    static var previews: some View {
        DayPlanView(dayDate: Date())
    }
}
