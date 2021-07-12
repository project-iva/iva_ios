//
//  ControlSessionsView.swift
//  iva_ios
//
//  Created by Igor Pidik on 11/07/2021.
//

import SwiftUI

struct ControlSessionsView: View {
    @State private var controlSessions = [ControlSessionListItem]()
    
    var body: some View {
        List(controlSessions, id: \.uuid) {  session in
            let text = Text(session.type.rawValue)
            switch session.type {
                case .mealChoices:
                    NavigationLink(destination: MealControlSessionView(sessionUUID: session.uuid))  {
                        text
                    }
                case .routine:
                    NavigationLink(destination: RoutineControlSessionView(sessionUUID: session.uuid)) {
                        text
                    }
            }
        }.onAppear(perform: loadSessions)
        .navigationTitle("Control Sessions")
    }
        
    func loadSessions() {
        print("loading")
        IvaClient.fetchControlSessions().done { result in
            controlSessions = result
        }.catch { error in
            print(error)
        }
    }
}

struct ControlSessionsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlSessionsView()
    }
}
