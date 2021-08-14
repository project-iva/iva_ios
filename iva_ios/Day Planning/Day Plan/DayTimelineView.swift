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
    let delegate: TimelineViewDelegate
    
    func makeUIViewController(context: Context) -> TimelineContainerController {
        let controller = TimelineContainerController()
        controller.timeline.delegate = delegate
        return controller
    }
    
    func updateUIViewController(_ uiViewController: TimelineContainerController, context: Context) {
        uiViewController.timeline.delegate = delegate
        uiViewController.timeline.layoutAttributes = activities.map({ EventLayoutAttributes(ActivityEvent(activity: $0)) })
    }
}

extension DayTimelineView {
    class Delegate: TimelineViewDelegate {
        private let didTap: (ActivityEvent) -> ()
        
        init(didTap: @escaping (ActivityEvent) -> ()) {
            self.didTap = didTap
        }
        
        func timelineView(_ timelineView: TimelineView, didTapAt date: Date) {}
        
        func timelineView(_ timelineView: TimelineView, didLongPressAt date: Date) {}
        
        func timelineView(_ timelineView: TimelineView, didTap event: EventView) {
            if let activityEvent = event.descriptor as? ActivityEvent {
                didTap(activityEvent)
            }
        }
        
        func timelineView(_ timelineView: TimelineView, didLongPress event: EventView) {}
    }
}
