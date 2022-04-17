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
    
    func toTimeString(format: String = "HH:mm:ss") -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = format
        timeFormatter.locale = Locale.current
        timeFormatter.timeZone = TimeZone.current
        
        return timeFormatter.string(from: self)
    }
}

// MARK: String Extensions
extension String {
    func toDateTime() -> Date {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        timeFormatter.locale = Locale.current
        timeFormatter.timeZone = TimeZone.current
        
        return Date().setTime(from: timeFormatter.date(from: self)!)
    }
}
