//
//  MindfulSession.swift
//  iva_ios
//
//  Created by Igor Pidik on 20/06/2021.
//

import Foundation


class MindfulSession: Codable {
    var uuid: UUID
    var sourceName: String
    var start: Date
    var end: Date
}
