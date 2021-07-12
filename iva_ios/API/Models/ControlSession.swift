//
//  ControlSession.swift
//  iva_ios
//
//  Created by Igor Pidik on 11/07/2021.
//

import Foundation

enum ControlSessionAction: String, Codable {
    case next
    case prev
    case confirm
}

enum ControlSessionType: String, Codable {
    case routine
    case mealChoices = "meal_choices"
}

struct ControlSessionListItem: Codable {
    let uuid: UUID
    let type: ControlSessionType
}

struct ControlSessionItem<T: Codable>: Codable {
    let data: T
    let validActions: [ControlSessionAction]
}

struct ControlSession<T: Codable>: Codable {
    let sessionType: ControlSessionType
    let items: [ControlSessionItem<T>]
}

struct ControlSessionResponse<T: Codable>: Codable {
    let controlSession: ControlSession<T>
    var currentItem: Int
}
