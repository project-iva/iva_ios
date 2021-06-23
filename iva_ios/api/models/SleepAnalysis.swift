//
//  SleepAnalysis.swift
//  iva_ios
//
//  Created by Igor Pidik on 22/06/2021.
//

import Foundation
import struct HealthKitReporter.Category

struct SleepAnalysis: Codable {
    let uuid: UUID
    let sourceName: String
    let start: Date
    let end: Date
    let value: Int
}

extension SleepAnalysis {
    init(category: Category) {
        self.init(uuid: UUID(uuidString: category.uuid)!, sourceName: category.sourceRevision.source.name,
                  start: category.startTimestamp.asDate, end: category.endTimestamp.asDate,
                  value: category.harmonized.value)
    }
}
