//
//  TemplateActivityView.swift
//  iva_ios
//
//  Created by Igor Pidik on 07/05/2022.
//

import SwiftUI

struct TemplateActivityView: View {
    var activity: DayPlanTemplateActivity

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Image(uiImage: activity.type.icon).resizable().frame(width: 64, height: 64)
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
                        Text(activity.startTime.toDateTime().toTimeString(format: "HH:mm"))
                    }
                    Spacer()
                    VStack {
                        Text("To").font(.footnote).fontWeight(.light)
                        Text(activity.endTime.toDateTime().toTimeString(format: "HH:mm"))
                    }
                }
            }
        }
    }
}
//
//struct TemplateActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        TemplateActivityView()
//    }
//}
