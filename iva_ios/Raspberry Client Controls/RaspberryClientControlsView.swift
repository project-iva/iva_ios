//
//  RaspberryClientControlsView.swift
//  iva_ios
//
//  Created by Igor Pidik on 28/09/2021.
//

import SwiftUI

struct RaspberryClientControlsView: View {
    var body: some View {
        return VStack {
            Button("Screen ON") {
                invokeAction(action: .screenOn)
            }
            Button("Screen OFF") {
                invokeAction(action: .screenOff)
            }
        }
    }
    
    private func invokeAction(action: RaspberryClientAction) {
        IvaClient.invokeRaspberryClient(action: action).catch { error in
            print(error)
        }
    }
}

struct RaspberryClientControlsView_Previews: PreviewProvider {
    static var previews: some View {
        RaspberryClientControlsView()
    }
}
