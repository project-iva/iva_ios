//
//  DayPlanModel.swift
//  iva_ios
//
//  Created by Igor Pidik on 15/05/2022.
//

import Foundation

class DayPlanModel: ObservableObject {
    @Published var currentActivity: DayPlanActivity?
    @Published var upcomingActivities = [DayPlanActivity]()
    @Published var pastActivities = [DayPlanActivity]()
    @Published private var activities = [DayPlanActivity]()
    private var dayPlanId = 0
    
    init() {
        fetchDayPlan()
    }
    
    private func fetchDayPlan() {
        IvaBackendClient.fetchDayPlan(for: Date()).done { dayPlan in
            self.dayPlanId = dayPlan.id
            self.activities = dayPlan.activities
            self.filterActivities()
        }.catch { error in
            print(error)
        }
    }
    
    private func filterActivities() {
        currentActivity = nil
        upcomingActivities = []
        pastActivities = []
        for activity in activities.sorted(by: { $0.startTime.toDateTime() < $1.startTime.toDateTime() }) {
            if activity.status == .current {
                currentActivity = activity
                continue
            }
            
            if activity.status == .finished || activity.status == .skipped {
                pastActivities.append(activity)
                continue
            }
            
            upcomingActivities.append(activity)
        }
    }
    
    func patchActivity(updatedActivity: DayPlanActivity, onDone: ((DayPlanActivity) -> (Void))? = nil) {
        IvaBackendClient.patchDayPlanActivity(dayPlanId: dayPlanId, activity: updatedActivity).done { patchedActivity in
            onDone?(patchedActivity)
        }.catch { error in
            print(error)
        }
    }
    
    func finishActivity(activity: DayPlanActivity, onDone: ((DayPlanActivity) -> (Void))? = nil) {
        // todo: find the proper activity
        let id = getActivityIndex(activity: activity)
        var updatedActivity = activities[id]
        updatedActivity.endedAt = Date().toTimeString()
        let onDone = onDone ?? { _ in self.fetchDayPlan()}
        patchActivity(updatedActivity: updatedActivity, onDone: onDone)
    }
    
    func finishActivityAndStartNext(activity: DayPlanActivity) {
        finishActivity(activity: activity) { _ in
            if var upcomingActivity = self.upcomingActivities.first {
                upcomingActivity.startedAt = Date().toTimeString()
                self.patchActivity(updatedActivity: upcomingActivity) { _ in
                    self.fetchDayPlan()
                }
            }
        }
    }
    
    func startActivity(activity: DayPlanActivity) {
        let id = getActivityIndex(activity: activity)
        var updatedActivity = activities[id]
        updatedActivity.startedAt = Date().toTimeString()
        patchActivity(updatedActivity: updatedActivity) { _ in
            if let currentActivity = self.currentActivity {
                self.finishActivity(activity: currentActivity)
            } else {
                self.fetchDayPlan()
            }
        }
    }
    
    func skipActivity(activity: DayPlanActivity) {
        let id = getActivityIndex(activity: activity)
        var patchActivity = activities[id]
        patchActivity.skipped = true
        IvaBackendClient.patchDayPlanActivity(dayPlanId: dayPlanId, activity: patchActivity).done { _ in
            self.fetchDayPlan()
        }.catch { error in
            print(error)
        }
    }
    
    func updateActivity(activity: DayPlanActivity) {
        patchActivity(updatedActivity: activity) { _ in
            self.fetchDayPlan()
        }
    }
    
    func deleteActivity(activity: DayPlanActivity) {
        IvaBackendClient.deleteDayPlanActivity(dayPlanId: dayPlanId, activity: activity).done { _ in
            self.fetchDayPlan()
        }.catch { error in
            print("Error deleting activity: \(error)")
        }
    }
    
    func createActivity(activity: DayPlanActivity) {
        IvaBackendClient.postDayPlanActivity(dayPlanId: dayPlanId, activity: activity).done { activity in
            self.upcomingActivities.append(activity)
        }.catch { err in
            print(err)
        }
    }
    
    private func getActivityIndex(activity: DayPlanActivity) -> Int {
        return activities.firstIndex { checkingActivity in
            return checkingActivity.id == activity.id
        }!
    }
}
