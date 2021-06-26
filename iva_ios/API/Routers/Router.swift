//
//  Router.swift
//  iva_ios
//
//  Created by Igor Pidik on 20/06/2021.
//

import Foundation
import Alamofire

protocol RouterProtocol: URLRequestConvertible {
    var method: HTTPMethod { get }
    var path: String { get }
    func addParametersToRequest(request: URLRequest) throws -> URLRequest
    func encodeModelIntoRequest<EncodableModel: Encodable>(model: EncodableModel, request: URLRequest) throws -> URLRequest
    func asURLRequest() throws -> URLRequest
}

extension RouterProtocol {
    var baseURL: URL {
        return URL(string: "http://192.168.0.101:8000/api/")!
    }

    func addParametersToRequest(request: URLRequest) throws -> URLRequest {
        return request
    }

    func encodeModelIntoRequest<EncodableModel: Encodable>(model: EncodableModel, request: URLRequest) throws -> URLRequest {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        return try JSONParameterEncoder(encoder: jsonEncoder).encode(model, into: request)
    }

    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method
        request = try addParametersToRequest(request: request)
        return request
    }
}

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
