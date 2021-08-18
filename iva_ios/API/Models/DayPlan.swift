//
//  DayPlan.swift
//  iva_ios
//
//  Created by Igor Pidik on 09/08/2021.
//

import Foundation

enum DayPlanActivityType: String, CaseIterable, Codable {
    case morningRoutine = "MORNING_ROUTINE"
    case eveningRoutine = "EVENINING_ROUTINE"
    case meal = "MEAL"
    case leisure = "LEISURE"
    case workout = "WORKOUT"
    case job = "JOB"
    case hobby = "HOBBY"
    case other = "OTHER"
    
    var displayName: String {
        switch self {
            case .morningRoutine:
                return "Morning routine"
            case .eveningRoutine:
                return "Evening routine"
            case .meal:
                return "Meal"
            case .leisure:
                return "Leisure"
            case .workout:
                return "Workout"
            case .job:
                return "Job"
            case .hobby:
                return "Hobby"
            case .other:
                return "Other"
        }
    }
}

struct DayPlanActivity: Codable, Identifiable {
    let id: Int
    var name: String
    var description: String
    var startTime: String
    var endTime: String
    var type: DayPlanActivityType
}

struct DayPlan: Codable {
    let id: Int
    let activities: [DayPlanActivity]
    let date: String
}
