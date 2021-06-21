//
//  Router.swift
//  iva_ios
//
//  Created by Igor Pidik on 20/06/2021.
//

import Foundation
import Alamofire

protocol Router: URLRequestConvertible {
    var method: HTTPMethod { get }
    var path: String { get }
    func addParametersToRequest(request: URLRequest) throws -> URLRequest
    func asURLRequest() throws -> URLRequest
}

extension Router {
    var baseURL: URL {
        return URL(string: "http://192.168.0.101:8000/api/")!
    }
    
    func addParametersToRequest(request: URLRequest) throws -> URLRequest {
        return request
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        print(url)
        var request = URLRequest(url: url)
        request.method = method
        request = try addParametersToRequest(request: request)
        return request
    }
}

enum MindfulSessionRouter: Router {
    case get(Int? = nil)
    
    var method: HTTPMethod {
        switch self {
            case .get: return .get
        }
    }
    
    var path: String {
        let mindfulSessionEndpoint = "mindful-sessions/"
        switch self {
            case .get: return mindfulSessionEndpoint
        }
    }
    
    func addParametersToRequest(request: URLRequest) throws -> URLRequest {
        switch self {
            case .get(let limit):
                if let limit = limit {
                    let requestWithLimit = try URLEncodedFormParameterEncoder().encode(["limit": limit], into: request)
                    return requestWithLimit
                }
                return request
        }
    }
}
