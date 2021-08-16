//
//  DayGoalsView.swift
//  iva_ios
//
//  Created by Igor Pidik on 09/08/2021.
//

import SwiftUI

struct DayGoalsView: View {
    var dayDate: Date
    @State private var dayGoals: [DayGoal] = []
    @State private var dayGoalsListId: Int = 0
    @Environment(\.editMode) var editMode
    @State var editingDayGoal: DayGoal?
    @State var addingDayGoal = false
    
    var body: some View {
        List {
            ForEach(dayGoals, id: \.id) { goal in
                let index = dayGoals.firstIndex { checkingGoal in
                    return checkingGoal.id == goal.id
                    
                }!
                
                Toggle(isOn: Binding(get: { dayGoals[index].finished },
                                     set: { dayGoals[index].finished = $0 })) {
                    VStack(alignment: .leading) {
                        Text(goal.name)
                        Text(goal.description).fontWeight(.light)
                        
                    }
                }
                .onChange(of: dayGoals[index].finished) { _ in
                    patchDayGoal(index: index)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if editMode?.wrappedValue.isEditing ?? false {
                        editingDayGoal = goal
                    }
                }
            }
            .onDelete(perform: deleteDayGoal)
            
        }
        .onChange(of: dayDate, perform: { newDayDate in
            fetchDayGoals(for: newDayDate)
        })
        .onAppear(perform: {
            fetchDayGoals(for: dayDate)
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    addingDayGoal = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .sheet(item: $editingDayGoal, onDismiss: {
            editMode?.wrappedValue = .inactive
        }, content: { dayGoal in
            EditDayGoal(dayGoal: dayGoal, addingDayGoal: false) { updatedDayGoal in
                let index = dayGoals.firstIndex { checkingDayGoal in
                    return checkingDayGoal.id == updatedDayGoal.id
                }!
                dayGoals[index] = updatedDayGoal
                editingDayGoal = nil
                patchDayGoal(index: index)
            } onDeleteAction: { deletedDayGoal in
                let index = dayGoals.firstIndex { checkingDayGoal in
                    return checkingDayGoal.id == deletedDayGoal.id
                }!
                editingDayGoal = nil
                deleteDayGoal(at: IndexSet([index]))
            }
        })
        .sheet(isPresented: $addingDayGoal) {
            let dayGoal = DayGoal(id: -1, name: "", description: "", finished: false)
            EditDayGoal(dayGoal: dayGoal, addingDayGoal: true) { newDayGoal in
                addingDayGoal = false
                IvaBackendClient.posthDayGoal(goalsListId: dayGoalsListId, goal: newDayGoal).done { responseDayGoal in
                    dayGoals.append(responseDayGoal)
                }.catch { error in
                    print("Error adding day goal: \(error)")
                }
            }
        }
    }
    
    private func fetchDayGoals(for date: Date) {
        IvaBackendClient.fetchDayGoals(for: date).done { result in
            dayGoals = result.goals
            dayGoalsListId = result.id
        }.catch { error in
            print(error)
        }
    }
    
    private func patchDayGoal(index: Int) {
        let goal = dayGoals[index]
        IvaBackendClient.patchDayGoal(goalsListId: dayGoalsListId, goal: goal).catch { error in
            print(error)
        }
    }
    
    private func deleteDayGoal(at offsets: IndexSet) {
        offsets.forEach { index in
            print(index)
            IvaBackendClient.deleteDayGoal(goalsListId: dayGoalsListId, goal: dayGoals[index]).catch { error in
                print(error)
            }
            
        }
        dayGoals.remove(atOffsets: offsets)
    }
}

struct DayGoalsView_Previews: PreviewProvider {
    static var previews: some View {
        DayGoalsView(dayDate: Date())
    }
}
