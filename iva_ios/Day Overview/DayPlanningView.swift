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
    
    var body: some View {
        List(activities) { activity in
            ActivityView(activity: activity)
            
        }.onChange(of: dayDate) { newDate in
            fetchDayPlan(for: newDate)
        }.onAppear {
            fetchDayPlan(for: dayDate)
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
