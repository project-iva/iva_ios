//
//  SleepAnalysis.swift
//  iva_ios
//
//  Created by Igor Pidik on 22/06/2021.
//

import Foundation
import struct HealthKitReporter.Category

class SleepAnalysis: CategoryModel {
    let value: Int

    init(uuid: UUID, sourceName: String, start: Date, end: Date, value: Int) {
        self.value = value
        super.init(uuid: uuid, sourceName: sourceName, start: start, end: end)
    }

    convenience init(category: Category) {
        self.init(uuid: UUID(uuidString: category.uuid)!, sourceName: category.sourceRevision.source.name,
                  start: category.startTimestamp.asDate, end: category.endTimestamp.asDate,
                  value: category.harmonized.value)
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
