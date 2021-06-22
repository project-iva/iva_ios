//
//  CategoryModel.swift
//  iva_ios
//
//  Created by Igor Pidik on 22/06/2021.
//

import Foundation
import struct HealthKitReporter.Category


class CategoryModel: Codable {
    let uuid: UUID
    let sourceName: String
    let start: Date
    let end: Date
    
    init(uuid: UUID, sourceName: String, start: Date, end: Date) {
        self.uuid = uuid
        self.sourceName = sourceName
        self.start = start
        self.end = end
    }
    
    convenience init(category: Category) {
        self.init(uuid: UUID(uuidString: category.uuid)!, sourceName: category.sourceRevision.source.name, start: category.startTimestamp.asDate, end: category.endTimestamp.asDate)
    }
}
