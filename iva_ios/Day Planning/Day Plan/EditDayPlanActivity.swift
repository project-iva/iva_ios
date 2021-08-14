//
//  EditDayPlanActivity.swift
//  iva_ios
//
//  Created by Igor Pidik on 14/08/2021.
//

import SwiftUI

struct EditDayPlanActivity: View {
    @State var activity: DayPlanActivity
    var onUpdatedAction: ((DayPlanActivity) -> Void)
    
    var body: some View {
        HStack {
            TextField("t", text: $activity.description)
            Button("Save") {
                onUpdatedAction(activity)
            }
        }
    }
}
