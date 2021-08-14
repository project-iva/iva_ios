//
//  ActivityEvent.swift
//  iva_ios
//
//  Created by Igor Pidik on 14/08/2021.
//

import CalendarKit

public final class ActivityEvent: EventDescriptor {
    public var startDate = Date()
    public var endDate = Date()
    public var isAllDay = false
    public var text = ""
    public var attributedText: NSAttributedString?
    public var lineBreakMode: NSLineBreakMode?
    public var color = SystemColors.systemBlue
    public var backgroundColor = SystemColors.systemBlue.withAlphaComponent(0.3)
    public var textColor = SystemColors.label
    public var font = UIFont.boldSystemFont(ofSize: 12)
    public var userInfo: Any?
    public weak var editedEvent: EventDescriptor?
    var activity: DayPlanActivity
    
    private let timeFormatter: DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        timeFormatter.locale = Locale.current
        timeFormatter.timeZone = TimeZone.current
        return timeFormatter
    }()
    
    init(activity: DayPlanActivity) {
        self.activity = activity
        startDate = Date().setTime(from: timeFormatter.date(from: activity.startTime)!)
        endDate = Date().setTime(from: timeFormatter.date(from: activity.endTime)!)
        
        text = """
        \(activity.name)
        \(activity.description)
        \(startDate.formatted(with: "HH:mm")) - \(endDate.formatted(with: "HH:mm"))
        """
    }
    
    public func makeEditable() -> ActivityEvent {
        return self
    }
    
    public func commitEditing() {
    }
}
