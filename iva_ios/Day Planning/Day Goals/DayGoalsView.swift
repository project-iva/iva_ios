//
//  DayGoalsView.swift
//  iva_ios
//
//  Created by Igor Pidik on 09/08/2021.
//

import SwiftUI

struct DayGoalsView: View {
    @State private var dayGoals: [DayGoal] = []
    @State private var dayGoalsListId: Int = 0
    
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
                }.onChange(of: dayGoals[index].finished) { _ in
                    patchDayGoal(index: index)
                }
            }.onDelete(perform: deleteDayGoal)
            
        }.onAppear(perform: fetchDayGoals)
    }
    
    private func fetchDayGoals() {
        print("loading")
        IvaBackendClient.fetchCurrentDayGoals().done { result in
            dayGoals = result.goals
            dayGoalsListId = result.id
        }.catch { error in
            print(error)
        }
    }
    
    private func patchDayGoal(index: Int) {
        print("patch")
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
        DayGoalsView()
    }
}
