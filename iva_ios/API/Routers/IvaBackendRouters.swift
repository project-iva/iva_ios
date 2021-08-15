//
//  IvaBackendRouters.swift
//  iva_ios
//
//  Created by Igor Pidik on 12/07/2021.
//

import Foundation
import Alamofire

enum ModelViewSetRouter<T: Encodable>: RouterProtocol {
    case get(Int? = nil)
    case post(T)
    
    var method: HTTPMethod {
        switch self {
            case .get: return .get
            case .post: return .post
        }
    }
    
    var path: String {
        return RouterHelper.getEndpoint(for: T.self)
    }
    
    func addParametersToRequest(request: URLRequest) throws -> URLRequest {
        switch self {
            case .get(let limit):
                if let limit = limit {
                    let requestWithLimit = try URLEncodedFormParameterEncoder().encode(["limit": limit], into: request)
                    return requestWithLimit
                }
                return request
                
            case .post(let model):
                return try encodeModelIntoRequest(model: model, request: request)
        }
    }
}

enum CurrentDayPlanRouter: RouterProtocol {
    case get
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "current-day-plan/"
    }
}

enum DayPlanRouter: RouterProtocol {
    case patch(Int, DayPlanActivity)
    case delete(Int, DayPlanActivity)
    case post(Int, DayPlanActivity)
    
    var method: HTTPMethod {
        switch self {
            case .delete:
                return .delete
            case .patch:
                return .patch
            case .post:
                return .post
        }
    }
    
    var path: String {
        switch self {
            case .delete(let dayPlanId, let activity), .patch(let dayPlanId, let activity):
                return "day-plans/\(dayPlanId)/activities/\(activity.id)/"
            case .post(let dayPlanId, _):
                return "day-plans/\(dayPlanId)/activities/"
        }
    }
    
    
    func addParametersToRequest(request: URLRequest) throws -> URLRequest {
        switch self {
            case .delete:
                return request
            case .patch(_, let activity), .post(_, let activity):
                return try encodeModelIntoRequest(model: activity, request: request)
        }
    }
}

enum CurrentDayGoalsRouter: RouterProtocol {
    case get
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "current-day-goals/"
    }
}


enum DayGoalRouter: RouterProtocol {
    case post(Int, DayGoal)
    case patch(Int, DayGoal)
    case delete(Int, DayGoal)
    
    var method: HTTPMethod {
        switch self {
            case .delete:
                return .delete
            case .patch:
                return .patch
            case .post:
                return .post
        }
    }
    
    var path: String {
        switch self {
            case .delete(let goalsListId, let goal), .patch(let goalsListId, let goal):
                return "day-goals/\(goalsListId)/goals/\(goal.id)/"
            case .post(let goalsListId, _):
                return "day-goals/\(goalsListId)/goals/"
        }
    }
    
    func addParametersToRequest(request: URLRequest) throws -> URLRequest {
        switch self {
            case .delete:
                return request
            case .patch(_, let goal), .post(_, let goal):
                return try encodeModelIntoRequest(model: goal, request: request)
        }
    }
}
