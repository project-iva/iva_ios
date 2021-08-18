//
//  EditDayGoal.swift
//  iva_ios
//
//  Created by Igor Pidik on 15/08/2021.
//

import SwiftUI

struct EditDayGoal: View {
    @State var dayGoal: DayGoal
    @State var addingDayGoal: Bool
    var onSaveAction: ((DayGoal) -> Void)
    var onDeleteAction: ((DayGoal) -> Void)?
    
    var body: some View {
        VStack {
            if addingDayGoal {
                Text("Create Goal").font(.title)
            } else {
                Text("Edit Goal").font(.title)
            }
            TextField("Goal name", text: $dayGoal.name).textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Description", text: $dayGoal.description).textFieldStyle(RoundedBorderTextFieldStyle())
            Spacer()
            HStack {
                if !addingDayGoal {
                    Button("Delete") {
                        onDeleteAction?(dayGoal)
                    }.foregroundColor(.red)
                    
                    Spacer()
                }
                
                Button("Save") {
                    onSaveAction(dayGoal)
                }
            }
        }.padding()
    }
}
