//
//  Responses.swift
//  iva_ios
//
//  Created by Igor Pidik on 20/06/2021.
//

import Foundation

class APIResponse {
    let statusCode: Int?
    let headers: [String: String]
    
    init(statusCode: Int?, headers: [String: String]) {
        self.statusCode = statusCode
        self.headers = headers
    }
}

class SuccessfulAPIResponse<T: Decodable>: APIResponse {
    let result: T
    init(result: T, statusCode: Int?, headers: [String: String]) {
        self.result = result
        super.init(statusCode: statusCode, headers: headers)
    }
}

class ErrorAPIResponse: APIResponse, Error {
    let error: Error
    let errorData: Data?
    
    init(error: Error, errorData: Data?, statusCode: Int?, headers: [String: String]) {
        self.error = error
        self.errorData = errorData
        super.init(statusCode: statusCode, headers: headers)
    }
}
