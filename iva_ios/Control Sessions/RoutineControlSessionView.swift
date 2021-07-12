//
//  RoutineControlSessionView.swift
//  iva_ios
//
//  Created by Igor Pidik on 12/07/2021.
//

import SwiftUI

struct RoutineControlSessionView: ControlSessionView {
    typealias ControlSessionItemDataType = RoutineStep
    let sessionUUID: UUID
    @State var controlSession: ControlSessionResponse<RoutineStep>?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        if let currentItem = self.getCurrentSessionItem() {
            Text(currentItem.data.title)
            Text(currentItem.data.description)
            getControls(currentItem: currentItem)
        } else {
            self.loadingView.onAppear(perform: loadSession)
        }
    }
    
    func loadSession() {
        IvaClient.fetchSessionDetails(sessionUUID: sessionUUID).done { response in
            controlSession = response
        }.catch { error in
            print(error)
        }
    }
    
    func handleAction(action: ControlSessionAction) {
        var completionHandler: (() -> ())?
        
        switch action {
            case .next:
                completionHandler = {
                    controlSession?.currentItem += 1
                }
            case .prev:
                break
            case .confirm:
                completionHandler = {
                    presentationMode.wrappedValue.dismiss()
                }
        }
        postControlAction(action: action, completionHandler: completionHandler)
    }
    
    func handleError(error: Error) {
        print(error)
    }
}
