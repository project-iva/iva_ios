//
//  Extensions.swift
//  iva_ios
//
//  Created by Igor Pidik on 11/08/2021.
//

import Foundation
import CalendarKit

// MARK: Date Extensions
extension Date {
    func setTime(from date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        
        components.hour = calendar.component(.hour, from: date)
        components.minute = calendar.component(.minute, from: date)
        components.second = calendar.component(.second, from: date)
        
        return calendar.date(from: components)!
    }
}
