//
//  ControlSession.swift
//  iva_ios
//
//  Created by Igor Pidik on 11/07/2021.
//

import Foundation

struct ControlSessionListItem: Codable {
    let uuid: UUID
    let type: String
}

enum ControlSessionAction: String, Codable {
    case next
    case prev
    case confirm
}

struct ControlSessionItem<T: Codable>: Codable {
    let data: T
    let validActions: [ControlSessionAction]
}

struct ControlSession<T: Codable>: Codable {
    let sessionType: String
    let items: [ControlSessionItem<T>]
}

struct ControlSessionResponse<T: Codable>: Codable {
    let controlSession: ControlSession<T>
    var currentItem: Int
}
