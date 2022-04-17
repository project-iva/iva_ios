//
//  DayOverviewView.swift
//  iva_ios
//
//  Created by Igor Pidik on 15/04/2022.
//

import SwiftUI

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
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            if currentActivity != nil {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Current activity").font(.title)
                    ActivityView(activity: currentActivity!)
                }.padding().onReceive(timer) { _ in
                    timeRemaining += 1
                }
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
            
            switch overviewSegment {
                case .upcoming:
                    List(upcomingActivities) { upcomingActivity in
                        Text(upcomingActivity.name)
                    }
                case .history:
                    List {
                        ForEach(pastActivities) { pastActivity in
                            Text(pastActivity.name).listRowInsets(.init(top: 25, leading: 25, bottom: 25, trailing: 25))
                        }
                    }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
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
        print(activities)
        currentActivity = nil
        upcomingActivities = []
        pastActivities = []
        for activity in activities.sorted(by: { $0.startTime.toDateTime() < $1.startTime.toDateTime() }) {
            if activity.startedAt != nil && activity.endedAt == nil {
                currentActivity = activity
                continue
            }
            
            if activity.endedAt != nil || activity.skipped {
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
