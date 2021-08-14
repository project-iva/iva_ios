//
//  DayPlan.swift
//  iva_ios
//
//  Created by Igor Pidik on 09/08/2021.
//

import Foundation

struct DayPlanActivity: Codable, Identifiable {
    let id: Int
    let name: String
    var description: String
    let startTime: String
    let endTime: String
}

struct DayPlan: Codable {
    let id: Int
    let activities: [DayPlanActivity]
    let date: String
}
