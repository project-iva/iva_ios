//
//  VoiceControlView.swift
//  iva_ios
//
//  Created by Igor Pidik on 10/11/2021.
//

import SwiftUI

enum VoiceControlState {
    case ready
    case listening
    case processing
}

struct VoiceControlView: View {
    private let voiceControlHelper = VoiceControlHelper()
    @State private var voiceControlState = VoiceControlState.ready
    @State private var recognizedText = ""
    var body: some View {
        Text(recognizedText)
        switch voiceControlState {
            case .ready:
                Button("Start", action: start)
            case .listening:
                Button("Stop") {
                    voiceControlHelper.stop()
                }
            case .processing:
                Text("Processing")
        }
    }
    
    private func start() {
        recognizedText = ""
        voiceControlState = .listening
        voiceControlHelper.start { result in
            if let result = result {
                recognizedText = result
                post(utterance: result)
            } else {
                voiceControlState = .ready
            }
        }
    }
    
    private func post(utterance: String) {
        voiceControlState = .processing
        IvaClient.postUtterance(utterance: utterance).catch { error in
            print(error)
        }.finally {
            voiceControlState = .ready
        }
    }
}

struct VoiceControlView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceControlView()
    }
}
