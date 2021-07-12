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
            NavigationLink(destination: ControlSessionsView()) {
                Text("Go")
            }
//            Button(action: {
//
//            }, label: {
//                HStack {
//                    Image(systemName: "arrowtriangle.forward.fill")
//                        .font(.title)
//                    Text("Next")
//                        .fontWeight(.semibold)
//                        .font(.title)
//                }
//                .padding()
//                .foregroundColor(.white)
//                .background(Color.blue)
//                .cornerRadius(40)
//            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
