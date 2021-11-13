//
//  VoiceControlWatch.swift
//  iva_ios
//
//  Created by Igor Pidik on 12/11/2021.
//

import SwiftUI
import WatchKit

struct VoiceControlViewWatch: View {
    private let suggestions = ["What's the time?", "Turn on the screen", "Turn off the screen", "Play music"]
    var body: some View {
        Button("Command") {
            WKExtension.shared().visibleInterfaceController?.presentTextInputController(
                withSuggestions: suggestions,
                allowedInputMode: .plain) { (results) in
                    if let utterances = results as? [String], !utterances.isEmpty {
                        let utterance = utterances[0]
                        post(utterance: utterance)
                    }
                }
        }
    }
    
    private func post(utterance: String) {
        IvaClient.postUtterance(utterance: utterance).catch { error in
            print(error)
        }
    }
}

struct VoiceControlViewWatch_Previews: PreviewProvider {
    static var previews: some View {
        VoiceControlViewWatch()
    }
}
