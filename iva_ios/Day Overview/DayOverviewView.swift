//
//  DayOverviewView.swift
//  iva_ios
//
//  Created by Igor Pidik on 15/04/2022.
//

import SwiftUI
import PromiseKit

enum OverviewSegment: String, CaseIterable {
    case upcoming = "Upcoming"
    case history = "History"
}

struct DayOverviewView: View {
    @State private var overviewSegment: OverviewSegment = .upcoming
    @State private var currentActivity: DayPlanActivity?
    @State private var upcomingActivities: [DayPlanActivity] = []
    @State private var pastActivities: [DayPlanActivity] = []
    @State private var activities: [DayPlanActivity] = []
    @State private var dayPlanId: Int = 0
    @State private var showActionSheet = false
    @State private var actionSheetActivity: DayPlanActivity?
    @Environment(\.editMode) private var editMode
    @State private var showAddActionSheet = false
    @State private var editingActivity: DayPlanActivity?
    
    var body: some View {
        VStack {
            if currentActivity != nil {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Current activity").font(.title)
                    ZStack {
                        ActivityView(activity: currentActivity!)
                            .padding()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if editMode?.wrappedValue.isEditing ?? false {
                                    editingActivity = currentActivity
                                } else {
                                    actionSheetActivity = currentActivity
                                    showActionSheet = true
                                }
                            }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }.padding()
            }
            VStack(alignment: .leading) {
                if currentActivity != nil {
                    Text("Other activities").font(.title)
                } else {
                    Text("Activities").font(.title)
                }
                Picker("Overview", selection: $overviewSegment) {
                    ForEach(OverviewSegment.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }.pickerStyle(SegmentedPickerStyle())
            }.padding()
            
            let otherActivities: [DayPlanActivity] = {
                switch overviewSegment {
                    case .upcoming:
                        return upcomingActivities
                    case .history:
                        return pastActivities
                }
            }()
            List(otherActivities) { activity in
                ActivityView(activity: activity)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if editMode?.wrappedValue.isEditing ?? false {
                            editingActivity = activity
                        } else {
                            actionSheetActivity = activity
                            showActionSheet = true
                        }
                    }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
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
        .actionSheet(isPresented: $showActionSheet, content: {
            guard var actionSheetActivity = actionSheetActivity else {
                fatalError("Action sheet activity is null")
            }
            
            if actionSheetActivity.status == .current {
                return ActionSheet(title: Text("Manage current activity"), buttons: [
                    .default(Text("Finish")) {
                        actionSheetActivity.endedAt = Date().toTimeString()
                        IvaBackendClient.patchDayPlanActivity(dayPlanId: dayPlanId, activity: actionSheetActivity).done { _ in
                            fetchDayPlan()
                        }.catch { error in
                            print(error)
                        }
                    },
                    .default(Text("Finish and start next activity")) {
                        actionSheetActivity.endedAt = Date().toTimeString()
                        var promises = [IvaBackendClient.patchDayPlanActivity(dayPlanId: dayPlanId, activity: actionSheetActivity)]
                        if var upcomingActivity = upcomingActivities.first {
                            upcomingActivity.startedAt = Date().toTimeString()
                            promises.append(IvaBackendClient.patchDayPlanActivity(dayPlanId: dayPlanId, activity: upcomingActivity))
                        }
                        
                        when(fulfilled: promises).done { _ in
                            fetchDayPlan()
                        }.catch { error in
                            print(error)
                        }
                        
                    },
                    .cancel()
                ])
            } else {
                return ActionSheet(title: Text("Manage upcoming activity"), buttons: [
                    .default(Text("Start activity")) {
                        actionSheetActivity.startedAt = Date().toTimeString()
                        var promises = [IvaBackendClient.patchDayPlanActivity(dayPlanId: dayPlanId, activity: actionSheetActivity)]
                        
                        // finish current activity
                        if currentActivity != nil {
                            currentActivity!.endedAt = Date().toTimeString()
                            promises.append(IvaBackendClient.patchDayPlanActivity(dayPlanId: dayPlanId, activity: currentActivity!))
                        }
                        when(fulfilled: promises).done { _ in
                            fetchDayPlan()
                        }.catch { error in
                            print(error)
                        }
                    },
                    .default(Text("Skip activity")) {
                        actionSheetActivity.skipped = true
                        IvaBackendClient.patchDayPlanActivity(dayPlanId: dayPlanId, activity: actionSheetActivity).done { _ in
                            fetchDayPlan()
                        }.catch { error in
                            print(error)
                        }
                    },
                    .cancel()
                ])
            }
        })
        .sheet(item: $editingActivity, onDismiss: {
            editMode?.wrappedValue = .inactive
        }, content: { activity in
            EditDayPlanActivity(activity: activity, addingActivity: false) { updatedActivity in
                
                editingActivity = nil
                
                IvaBackendClient.patchDayPlanActivity(dayPlanId: dayPlanId, activity: updatedActivity).done { _ in
                    fetchDayPlan()
                }.catch { error in
                    print(updatedActivity)
                    print("Error updating day plan activity: \(error)")
                }
            } onDeleteAction: { deletedActivity in
                editingActivity = nil
                IvaBackendClient.deleteDayPlanActivity(dayPlanId: dayPlanId, activity: deletedActivity).done { _ in
                    fetchDayPlan()
                }.catch { error in
                    print("Error deleting activity: \(error)")
                }
            }
        })
        .onAppear(perform: fetchDayPlan)
    }
    
    private func fetchDayPlan() {
        IvaBackendClient.fetchDayPlan(for: Date()).done { dayPlan in
            dayPlanId = dayPlan.id
            filterActivities(dayPlan.activities)
        }.catch { error in
            print(error)
        }
    }
    
    private func filterActivities(_ activities: [DayPlanActivity]) {
        currentActivity = nil
        upcomingActivities = []
        pastActivities = []
        for activity in activities.sorted(by: { $0.startTime.toDateTime() < $1.startTime.toDateTime() }) {
            if activity.status == .current {
                currentActivity = activity
                continue
            }
            
            if activity.status == .finished || activity.status == .skipped {
                pastActivities.append(activity)
                continue
            }
            
            upcomingActivities.append(activity)
        }
        
    }
}

struct DayOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        DayOverviewView()
    }
}
