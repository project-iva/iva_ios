//
//  DayGoals.swift
//  iva_ios
//
//  Created by Igor Pidik on 09/08/2021.
//

import Foundation

struct DayGoal: Codable, Identifiable {
    let id: Int
    var name: String
    var description: String
    var finished: Bool
}

struct DayGoals: Codable {
    let id: Int
    var goals: [DayGoal]
    let date: String
}
