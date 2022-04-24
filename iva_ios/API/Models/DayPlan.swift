//
//  DayPlan.swift
//  iva_ios
//
//  Created by Igor Pidik on 09/08/2021.
//

import UIKit

enum DayPlanActivityType: String, CaseIterable, Codable {
    case morningRoutine = "MORNING_ROUTINE"
    case eveningRoutine = "EVENING_ROUTINE"
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
    
    var icon: UIImage {
        switch self {
            case .morningRoutine:
                return UIImage(named: "MorningIcon")!
            case .eveningRoutine:
                return UIImage(named: "EveningIcon")!
            case .meal:
                return UIImage(named: "MealIcon")!
            case .leisure:
                return UIImage(named: "LeisureIcon")!
            case .workout:
                return UIImage(named: "WorkoutIcon")!
            case .job:
                return UIImage(named: "JobIcon")!
            case .hobby:
                return UIImage(named: "HobbyIcon")!
            case .other:
                return UIImage(named: "OtherIcon")!
        }
    }
}

enum DayPlanActivityStatus {}

struct DayPlanActivity: Codable, Identifiable {
    enum Status: String {
        case upcoming = "Upcoming"
        case current = "Current"
        case finished = "Finished"
        case skipped = "Skipped"
    }
    
    let id: Int
    var name: String
    var description: String
    var startTime: String
    var endTime: String
    var startedAt: String?
    var endedAt: String?
    var skipped: Bool = false
    var type: DayPlanActivityType
    
    var status: Status {
        if self.startedAt != nil && self.endedAt == nil { return .current }
        if self.startedAt != nil && self.endedAt != nil { return .finished }
        if self.skipped { return .skipped }
        return .upcoming
    }
}

struct DayPlan: Codable {
    let id: Int
    let activities: [DayPlanActivity]
    let date: String
}

struct DayPlanTemplateActivity: Codable, Identifiable {
    let id: Int
    var name: String
    var description: String
    var startTime: String
    var endTime: String
    var type: DayPlanActivityType
}

struct DayPlanTemplate: Codable {
    let id: Int
    let name: String
    let activities: [DayPlanTemplateActivity]
}
