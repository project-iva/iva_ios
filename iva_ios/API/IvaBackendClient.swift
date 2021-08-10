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
    static func fetchCurrentDayPlan() -> Promise<DayPlan> {
        return Promise<DayPlan> { seal in
            ApiHandler.shared.makeRequest(request: CurrentDayPlanRouter.get,
                                          resultType: DayPlan.self).done { response in
                                            seal.fulfill(response.result)
                                          }.catch { error in
                                            seal.reject(error)
                                          }
        }
    }
    
    static func fetchCurrentDayGoals() -> Promise<DayGoals> {
        return Promise<DayGoals> { seal in
            ApiHandler.shared.makeRequest(request: CurrentDayGoalsRouter.get,
                                          resultType: DayGoals.self).done { response in
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
}
