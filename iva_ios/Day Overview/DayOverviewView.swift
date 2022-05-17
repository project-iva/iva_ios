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
    @StateObject private var model = DayPlanModel()
    @State private var overviewSegment: OverviewSegment = .upcoming
    @State private var showActionSheet = false
    @State private var actionSheetActivity: DayPlanActivity?
    @Environment(\.editMode) private var editMode
    @State private var showAddActionSheet = false
    @State private var editingActivity: DayPlanActivity?
    
    var body: some View {
        VStack {
            if model.currentActivity != nil {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Current activity").font(.title)
                    ZStack {
                        ActivityView(activity: model.currentActivity!)
                            .padding()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if editMode?.wrappedValue.isEditing ?? false {
                                    editingActivity = model.currentActivity
                                } else {
                                    actionSheetActivity = model.currentActivity
                                    showActionSheet = true
                                }
                            }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }.padding()
            }
            VStack(alignment: .leading) {
                if model.currentActivity != nil {
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
                        return model.upcomingActivities
                    case .history:
                        return model.pastActivities
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
                        } else if overviewSegment == .upcoming {
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
            guard let actionSheetActivity = actionSheetActivity else {
                fatalError("Action sheet activity is null")
            }
            
            if actionSheetActivity.status == .current {
                return ActionSheet(title: Text("Manage current activity"), buttons: [
                    .default(Text("Finish")) {
                        model.finishActivity(activity: actionSheetActivity)
                    },
                    .default(Text("Finish and start next activity")) {
                        model.finishActivityAndStartNext(activity: actionSheetActivity)
                    },
                    .cancel()
                ])
            } else {
                return ActionSheet(title: Text("Manage upcoming activity"), buttons: [
                    .default(Text("Start activity")) {
                        model.startActivity(activity: actionSheetActivity)
                    },
                    .default(Text("Skip activity")) {
                        model.skipActivity(activity: actionSheetActivity)
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
                model.updateActivity(activity: updatedActivity)
            } onDeleteAction: { deletedActivity in
                editingActivity = nil
                model.deleteActivity(activity: deletedActivity)
            }
        })
        .sheet(isPresented: $showAddActionSheet, content: {
            let activity = DayPlanActivity(
                id: -1, name: "", description: "",
                startTime: Date().toTimeString(), endTime: Date().toTimeString(),
                type: .other
            )
            
            EditDayPlanActivity(activity: activity, addingActivity: true) { newActivity in
                showAddActionSheet = false
                model.createActivity(activity: newActivity)
            }
        })
    }
    

}

struct DayOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        DayOverviewView()
    }
}
