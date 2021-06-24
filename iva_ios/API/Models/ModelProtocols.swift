//
//  ModelWithStartTime.swift
//  iva_ios
//
//  Created by Igor Pidik on 24/06/2021.
//

import Foundation

protocol ModelWithStartTime {
    var start: Date { get }
}

protocol ModelWithUUID {
    var uuid: UUID { get }
}

typealias ModelWithStartTimeAndUUID = ModelWithStartTime & ModelWithUUID
