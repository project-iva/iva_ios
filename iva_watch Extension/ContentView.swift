//
//  ContentView.swift
//  iva_watch Extension
//
//  Created by Igor Pidik on 10/05/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            NavigationLink(destination: ControlSessionsView()) {
                Text("Go")
            }
            
            NavigationLink(destination: RaspberryClientControlsView()) {
                Text("Raspberry controls")
            }
            
            NavigationLink(destination: VoiceControlViewWatch()) {
                Text("Voice control")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
