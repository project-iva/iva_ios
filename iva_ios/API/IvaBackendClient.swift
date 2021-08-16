//
//  IvaBackendClient.swift
//  iva_ios
//
//  Created by Igor Pidik on 09/08/2021.
//

import Foundation
import Alamofire
import PromiseKit

class IvaBackendClient {
    static func fetchDayPlan(for date: Date) -> Promise<DayPlan> {
        return Promise<DayPlan> { seal in
            ApiHandler.shared.makeRequest(request: DayPlanRouter.get(date),
                                          resultType: DayPlan.self).done { response in
                                            seal.fulfill(response.result)
                                          }.catch { error in
                                            seal.reject(error)
                                          }
        }
    }
    
    static func fetchDayGoals(for date: Date) -> Promise<DayGoals> {
        return Promise<DayGoals> { seal in
            ApiHandler.shared.makeRequest(request: DayGoalsRouter.get(date),
                                          resultType: DayGoals.self).done { response in
                                            seal.fulfill(response.result)
                                          }.catch { error in
                                            seal.reject(error)
                                          }
        }
    }
    
    static func posthDayGoal(goalsListId: Int, goal: DayGoal) -> Promise<DayGoal> {
        return Promise<DayGoal> { seal in
            ApiHandler.shared.makeRequest(request: DayGoalRouter.post(goalsListId, goal),
                                          resultType: DayGoal.self).done { response in
                                            seal.fulfill(response.result)
                                          }.catch { error in
                                            seal.reject(error)
                                          }
        }
    }
    
    static func patchDayGoal(goalsListId: Int, goal: DayGoal) -> Promise<DayGoal> {
        return Promise<DayGoal> { seal in
            ApiHandler.shared.makeRequest(request: DayGoalRouter.patch(goalsListId, goal),
                                          resultType: DayGoal.self).done { response in
                                            seal.fulfill(response.result)
                                          }.catch { error in
                                            seal.reject(error)
                                          }
        }
    }
    
    static func deleteDayGoal(goalsListId: Int, goal: DayGoal) -> Promise<Empty> {
        return Promise<Empty> { seal in
            ApiHandler.shared.makeRequest(request: DayGoalRouter.delete(goalsListId, goal),
                                          resultType: Empty.self).done { response in
                                            seal.fulfill(response.result)
                                          }.catch { error in
                                            seal.reject(error)
                                          }
        }
    }
    
    static func postDayPlanActivity(dayPlanId: Int, activity: DayPlanActivity) -> Promise<DayPlanActivity> {
        return Promise<DayPlanActivity> { seal in
            ApiHandler.shared.makeRequest(request: DayPlanActivityRouter.post(dayPlanId, activity),
                                          resultType: DayPlanActivity.self).done { response in
                                            seal.fulfill(response.result)
                                          }.catch { error in
                                            seal.reject(error)
                                          }
        }
    }
    
    static func patchDayPlanActivity(dayPlanId: Int, activity: DayPlanActivity) -> Promise<DayPlanActivity> {
        return Promise<DayPlanActivity> { seal in
            ApiHandler.shared.makeRequest(request: DayPlanActivityRouter.patch(dayPlanId, activity),
                                          resultType: DayPlanActivity.self).done { response in
                                            seal.fulfill(response.result)
                                          }.catch { error in
                                            seal.reject(error)
                                          }
        }
    }
    
    static func deleteDayPlanActivity(dayPlanId: Int, activity: DayPlanActivity) -> Promise<Empty> {
        return Promise<Empty> { seal in
            ApiHandler.shared.makeRequest(request: DayPlanActivityRouter.delete(dayPlanId, activity),
                                          resultType: Empty.self).done { response in
                                            seal.fulfill(response.result)
                                          }.catch { error in
                                            seal.reject(error)
                                          }
        }
    }
}
