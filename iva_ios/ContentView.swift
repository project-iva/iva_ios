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
                    Text("Go")
                }
                
                NavigationLink(destination: DayView()) {
                    Text("Day")
                }
                
                NavigationLink(destination: RaspberryClientControlsView()) {
                    Text("Raspberry client controls")
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
