//
//  IvaController.swift
//  iva_ios
//
//  Created by Igor Pidik on 10/05/2021.
//

import Foundation
import Alamofire
import PromiseKit

class IvaClient {
    
    static func fetchControlSessions() -> Promise<[ControlSessionListItem]> {
        return Promise<[ControlSessionListItem]> { seal in
            ApiHandler.shared.makeRequest(request: ControlSessionsRouter.getControlSessions,
                                          resultType: [ControlSessionListItem].self).done { response in
                                            seal.fulfill(response.result)
                                          }.catch { error in
                                            seal.reject(error)
                                          }
        }
    }
    
    static func fetchSessionDetails<T>(sessionUUID: UUID) -> Promise<ControlSessionResponse<T>> {
        return Promise<ControlSessionResponse<T>> { seal in
            ApiHandler.shared.makeRequest(request: ControlSessionsRouter.getControlSession(sessionUUID),
                                          resultType: ControlSessionResponse<T>.self).done { response in
                                            seal.fulfill(response.result)
                                          }.catch { error in
                                            seal.reject(error)
                                          }
        }
    }
    
    static func postSessionAction(sessionUUID: UUID, action: ControlSessionAction) -> Promise<Empty> {
        return Promise<Empty> { seal in
            ApiHandler.shared.makeRequest(request: ControlSessionsRouter.postControlSessionAction(sessionUUID, action),
                                          resultType: Empty.self).done { response in
                                            seal.fulfill(response.result)
                                          }.catch { error in
                                            seal.reject(error)
                                          }
        }
    }
    
}
