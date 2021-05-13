//
//  AppDelegate.swift
//  iva_ios
//
//  Created by Igor Pidik on 13/05/2021.
//

import SwiftUI
import Starscream

class AppDelegate: NSObject, UIApplicationDelegate {
    private var socket: WebSocket!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Your code here")
        connectToWebsocketServer()
        return true
    }
    
    private func connectToWebsocketServer() {
        var request = URLRequest(url: URL(string: "ws://192.168.0.101:5678/ios")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        
        socket.onEvent = { event in
            switch event {
                case .connected(let headers):
                    print("websocket is connected: \(headers)")
                case .disconnected(let reason, let code):
                    print("websocket is disconnected: \(reason) with code: \(code)")
                case .text(let string):
                    print("Received text: \(string)")
                case .binary(let data):
                    print("Received data: \(data.count)")
                case .ping(_):
                    break
                case .pong(_):
                    break
                case .viabilityChanged(_):
                    break
                case .reconnectSuggested(_):
                    break
                case .cancelled:
                    break
                case .error(let error):
                    print("error")
                    print(error)
            }
        }
        
        socket.connect()
    }
}
