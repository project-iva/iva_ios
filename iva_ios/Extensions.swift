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

// MARK: DayPlanActivity Extensions
extension DayPlanActivity {
    func toCalendarEvent() -> Event {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        timeFormatter.locale = Locale.current
        timeFormatter.timeZone = TimeZone.current
        
        let event = Event()
        event.startDate = Date().setTime(from: timeFormatter.date(from: startTime)!)
        event.endDate = Date().setTime(from: timeFormatter.date(from: endTime)!)
        
        event.text = """
        \(name)
        \(description)
        \(event.startDate.formatted(with: "HH:mm")) - \(event.endDate.formatted(with: "HH:mm"))
        """

        return event
    }
}
