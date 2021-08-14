//
//  DayPlanView.swift
//  iva_ios
//
//  Created by Igor Pidik on 09/08/2021.
//

import SwiftUI

struct DayPlanView: View {
    @State private var activities: [DayPlanActivity] = []
    @Environment(\.editMode) var editMode
    @State var selection: Int?
    @State var editingActivity: DayPlanActivity?
    
    var body: some View {
        DayTimelineView(activities: $activities, delegate: DayTimelineView.Delegate(didTap: { activityEvent in
            print("tapped")
            if editMode?.wrappedValue.isEditing ?? false,
               let index = activities.firstIndex(where: { $0.id == activityEvent.activity.id }) {
                editingActivity = activities[index]
            }
        })).onAppear(perform: fetchDayPlan)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    print("add")
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .sheet(item: $editingActivity) { activity in
            EditDayPlanActivity(activity: activity) { updatedActivity in
                let index = activities.firstIndex { checkingActivity in
                    return checkingActivity.id == updatedActivity.id
                    
                }!
                activities[index] = updatedActivity
                editingActivity = nil
                editMode?.wrappedValue = .inactive
            }
        }
        
    }
    
    private func fetchDayPlan() {
        print("fetch")
        IvaBackendClient.fetchCurrentDayPlan().done { dayPlan in
            activities = dayPlan.activities
        }.catch { error in
            print(error)
        }
    }
}

struct DayPlanView_Previews: PreviewProvider {
    static var previews: some View {
        DayPlanView()
    }
}
