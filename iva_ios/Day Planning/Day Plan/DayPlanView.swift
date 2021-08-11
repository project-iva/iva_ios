//
//  DayPlanView.swift
//  iva_ios
//
//  Created by Igor Pidik on 09/08/2021.
//

import SwiftUI

struct DayPlanView: View {
    @State private var activities: [DayPlanActivity] = []
    var body: some View {
        DayTimelineView(activities: $activities).onAppear(perform: fetchDayPlan)
    }
    
    private func fetchDayPlan() {
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
