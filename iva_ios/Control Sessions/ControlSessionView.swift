//
//  ControlSessionView.swift
//  iva_ios
//
//  Created by Igor Pidik on 12/07/2021.
//

import SwiftUI

protocol ControlSessionView: View {
    associatedtype ControlSessionItemDataType: Codable
    var sessionUUID: UUID { get }
    var controlSession: ControlSessionResponse<ControlSessionItemDataType>? { get set }
    func handleAction(action: ControlSessionAction)
    func handleError(error: Error)
}

extension ControlSessionView {
    var loadingView: Text {
        return Text("Loading")
    }
    
    func getControls(currentItem: ControlSessionItem<ControlSessionItemDataType>) -> some View {
        return VStack {
            HStack {
                Button("Prev") {
                    handleAction(action: .prev)
                }.disabled(!currentItem.validActions.contains(.prev))
                Button("Next") {
                    handleAction(action: .next)
                }.disabled(!currentItem.validActions.contains(.next))
            }
            Button("Confirm") {
                handleAction(action: .confirm)
            }.disabled(!currentItem.validActions.contains(.confirm))
        }
        
    }
    
    func getCurrentSessionItem() -> ControlSessionItem<ControlSessionItemDataType>? {
        if let controlSession = controlSession {
            return controlSession.controlSession.items[controlSession.currentItem]
        }
        
        return nil
    }
    
    func postControlAction(action: ControlSessionAction, completionHandler: (() -> ())? = nil) {
        IvaClient.postSessionAction(sessionUUID: sessionUUID, action: action).done { _ in
            completionHandler?()
        }.catch { error in
            handleError(error: error)
        }
    }
}
