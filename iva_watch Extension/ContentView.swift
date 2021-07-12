//
//  ContentView.swift
//  iva_watch Extension
//
//  Created by Igor Pidik on 10/05/2021.
//

import SwiftUI

struct ContentView: View {
    private let ivaController = IvaClient()
    var body: some View {
        Button(action: {
        }, label: {
            HStack {
                Image(systemName: "arrowtriangle.forward.fill")
                    .font(.title)
                Text("Next")
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
