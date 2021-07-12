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
            NavigationLink(destination: MealControlSessionView(sessionUUID: session.uuid)) {
                Text(session.type)
            }
        }.onAppear(perform: loadSessions)
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
