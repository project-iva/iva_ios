//
//  ContentView.swift
//  iva_ios
//
//  Created by Igor Pidik on 07/05/2021.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: ControlSessionsView()) {
                    Text("Control sessions")
                }
                
                NavigationLink(destination: DayView()) {
                    Text("Day")
                }
                
                NavigationLink(destination: DayOverviewView()) {
                    Text("Day overview")
                }
                
                NavigationLink(destination: RaspberryClientControlsView()) {
                    Text("Raspberry client controls")
                }
                
                NavigationLink(destination: VoiceControlView()) {
                    Text("Voice control")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
