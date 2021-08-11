//
//  DayTimelineView.swift
//  iva_ios
//
//  Created by Igor Pidik on 11/08/2021.
//

import SwiftUI
import CalendarKit

struct DayTimelineView: UIViewControllerRepresentable {
    @Binding var activities: [DayPlanActivity]
    
    func makeUIViewController(context: Context) -> TimelineContainerController {
        return TimelineContainerController()
    }
    
    func updateUIViewController(_ uiViewController: TimelineContainerController, context: Context) {
        uiViewController.timeline.layoutAttributes = activities.map({ EventLayoutAttributes($0.toCalendarEvent()) })
        uiViewController.container.scrollToFirstEvent(animated: true)
    }
}
