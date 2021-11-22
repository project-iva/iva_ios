//
//  MealControlSessionView.swift
//  iva_ios
//
//  Created by Igor Pidik on 12/07/2021.
//

import SwiftUI

struct MealControlSessionView: ControlSessionView {
    typealias ControlSessionItemDataType = Meal
    let sessionUUID: UUID
    @State var controlSession: ControlSessionResponse<Meal>?
    
    var body: some View {
        if let currentItem = self.getCurrentSessionItem() {
            Text(currentItem.data.name)
            getControls(currentItem: currentItem)
        } else {
            self.loadingView.onAppear(perform: loadSession)
        }
    }
    
    private func loadSession() {
        IvaClient.fetchSessionDetails(sessionUUID: sessionUUID).done { response in
            controlSession = response
        }.catch { error in
            print(error)
        }
    }
    
    func handleAction(action: ControlSessionAction) {
        var completionHandler: (() -> Void)?
        
        switch action {
            case .next:
                completionHandler = {
                    controlSession?.currentItem += 1
                }
            case .prev:
                completionHandler = {
                    controlSession?.currentItem -= 1
                }
            case .confirm:
                break
        }
        postControlAction(action: action, completionHandler: completionHandler)
    }
    
    func handleError(error: Error) {
        print(error)
    }
}
