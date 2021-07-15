//
//  BodyMass.swift
//  iva_ios
//
//  Created by Igor Pidik on 15/07/2021.
//

import Foundation
import struct HealthKitReporter.Quantity

struct BodyMass: ModelWithStartTimeAndUUID, Codable {
    let uuid: UUID
    let start: Date
    let value: Double
}

extension BodyMass {
    init(quantity: Quantity) {
        self.init(uuid: UUID(uuidString: quantity.uuid)!, start: quantity.startTimestamp.asDate,
                  value: quantity.harmonized.value)
    }
}
