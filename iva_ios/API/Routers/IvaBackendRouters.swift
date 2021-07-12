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
