//
//  ApiHandler.swift
//  iva_ios
//
//  Created by Igor Pidik on 20/06/2021.
//

import Foundation
import class PromiseKit.Promise
import Alamofire


class ApiHandler {
    static let shared = ApiHandler()
    
    private init() {}
    
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601withFractionalSeconds
        return decoder
    }()
    
    
    func makeRequest<T>(request: URLRequestConvertible, resultType: T.Type) -> Promise<SuccessfulAPIResponse<T>> where T: Decodable {
        return Promise<SuccessfulAPIResponse<T>> { seal in
            AF.request(request)
                .validate()
                .responseDecodable(of: resultType, decoder: decoder) { response in
                    let statusCode = response.response?.statusCode
                    let headers = response.response?.allHeaderFields as? [String: String] ?? [:]
                    
                    switch response.result {
                        case .success(let result):
                            seal.fulfill(SuccessfulAPIResponse(result: result, statusCode: statusCode, headers: headers))
                        case .failure(let error):
                            print(error)
                            seal.reject(ErrorAPIResponse(error: error, errorData: response.data, statusCode: statusCode, headers: headers))
                    }
                }
        }
    }
}
