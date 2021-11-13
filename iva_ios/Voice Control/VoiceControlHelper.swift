//
//  VoiceControlHelper.swift
//  iva_ios
//
//  Created by Igor Pidik on 12/11/2021.
//

import SwiftUI
import Speech

class VoiceControlHelper {
    private let speechRecognizer = SFSpeechRecognizer()!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    func start(handler: @escaping (String?) -> Void) {
        SFSpeechRecognizer.requestAuthorization { [weak self] (authStatus) in
            switch authStatus {
                case .authorized:
                    do {
                        try self?.startRecording(handler: handler)
                    } catch let error {
                        print("There was a problem starting recording: \(error.localizedDescription)")
                    }
                case .denied:
                    print("Speech recognition authorization denied")
                    handler(nil)
                case .restricted:
                    print("Not available on this device")
                    handler(nil)
                case .notDetermined:
                    print("Not determined")
                    handler(nil)
                @unknown default:
                    fatalError()
            }
        }
    }
    
    private func startRecording(handler: @escaping (String?) -> Void) throws {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: [])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        self.recognitionRequest = recognitionRequest
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] (result, error) in
            guard let self = self else { return }
                        
            if let result = result, result.isFinal {
                self.stopRecording()
                handler(result.bestTranscription.formattedString)
            }
            
            if error != nil {
                print(error)
                self.stopRecording()
                handler(nil)
            }
        }
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    func stop() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest = nil
        recognitionTask = nil
    }
}
