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
                    ZStack {
                        ActivityView(activity: currentActivity!, isCurrentActivity: true)
                            .padding()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print("pressed")
                            }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
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
                    .contentShape(Rectangle())
                    .onTapGesture {
                        print("pressed 2")
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
