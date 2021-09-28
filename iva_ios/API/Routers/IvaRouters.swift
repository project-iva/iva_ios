//
//  IvaRouters.swift
//  iva_ios
//
//  Created by Igor Pidik on 12/07/2021.
//

import Foundation
import Alamofire

enum ControlSessionsRouter: RouterProtocol {
    case getControlSessions
    case getControlSession(UUID)
    case postControlSessionAction(UUID, ControlSessionAction)
    
    var method: HTTPMethod {
        switch self {
            case .postControlSessionAction(_, _):
                return .post
            default:
                return .get
        }
    }
    
    var baseURL: URL {
        return URL(string: "http://192.168.0.104:5000")!
    }
    
    var path: String {
        let controlSessionsPath = "/control-sessions/"
        switch self {
            case .getControlSessions:
                return controlSessionsPath
            case .getControlSession(let sessionUUID), .postControlSessionAction(let sessionUUID, _):
                return "\(controlSessionsPath)\(sessionUUID.uuidString)/"
                
        }
    }
    
    func addParametersToRequest(request: URLRequest) throws -> URLRequest {
        switch self {
            case .postControlSessionAction(_, let action):
                return try URLEncodedFormParameterEncoder().encode(["action": action.rawValue], into: request)
            default:
                return request
        }
    }
}

enum RaspberryClientRouter: RouterProtocol {
    case invokeAction(RaspberryClientAction)
    
    var method: HTTPMethod {
        return .post
    }
    
    var baseURL: URL {
        return URL(string: "http://192.168.0.104:5000")!
    }
    
    var path: String {
        return "/invoke-raspberry-client-action/"
    }
    
    func addParametersToRequest(request: URLRequest) throws -> URLRequest {
        switch self {
            case .invokeAction(let action):
                return try URLEncodedFormParameterEncoder().encode(["action": action.rawValue], into: request)
        }
    }
}
