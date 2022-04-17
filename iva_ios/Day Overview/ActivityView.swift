//
//  ActivityView.swift
//  iva_ios
//
//  Created by Igor Pidik on 17/04/2022.
//

import SwiftUI

struct ActivityView: View {
    var activity: DayPlanActivity
    private var startTime: String {
        if activity.startedAt != nil {
            return activity.startedAt!
        }
        return activity.startTime
    }
    
    private var endTime: String {
        if activity.endedAt != nil {
            return activity.endedAt!
        }
        
        if activity.startedAt != nil {
            // offset end time by the offset between expected start and actual start
            let offset = activity.startTime.toDateTime().distance(to: activity.startedAt!.toDateTime())
            return activity.endTime.toDateTime().addingTimeInterval(offset).toTimeString()
        }
        
        return activity.endTime
    }
    
    private var timespanSeconds: Int {
        Int(startTime.toDateTime().distance(to: endTime.toDateTime()))
    }
    
    @State private var elapsedTime = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        VStack {
            VStack {
                HStack(spacing: 10) {
                    Image(systemName: "pencil.circle.fill").resizable()
                        .frame(width: 64, height: 64)
                    VStack(alignment: .leading) {
                        Text(activity.name).font(.headline)
                        Text(activity.description).fontWeight(.light).lineLimit(3)
                    }
                    Spacer()
                }
                VStack {
                    HStack {
                        VStack {
                            Text("From").font(.footnote).fontWeight(.light)
                            Text(startTime.toDateTime().toTimeString(format: "HH:mm"))
                        }
                        Spacer()
                        VStack {
                            Text("Progress").font(.footnote).fontWeight(.light)
                            Text("\(formatSeconds(elapsedTime)) / \(formatSeconds(timespanSeconds))")
                        }
                        
                        Spacer()
                        VStack {
                            Text("To").font(.footnote).fontWeight(.light)
                            Text(endTime.toDateTime().toTimeString(format: "HH:mm"))
                        }
                    }
                    ProgressView(value: Double(min(elapsedTime, timespanSeconds)), total: Double(timespanSeconds)).onReceive(timer) { time in
                        elapsedTime = Int(abs(time.distance(to: startTime.toDateTime())))
                    }
                }
            }.padding()
        }.background(Color(.systemGray6)).cornerRadius(10)
    }
    
    private func formatSeconds(_ seconds: Int) -> String {
        let formattedMinutes = seconds / 60
        let formattedSeconds = seconds % 60
        return String(format: "%02d:%02d", formattedMinutes, formattedSeconds)
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(activity: DayPlanActivity(id: 1, name: "Activity", description: "Activity description", startTime: "14:00", endTime: "15:00", startedAt: nil, endedAt: nil, skipped: false, type: .other))
    }
}
