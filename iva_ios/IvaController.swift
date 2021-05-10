//
//  IvaController.swift
//  iva_ios
//
//  Created by Igor Pidik on 10/05/2021.
//

import Foundation
import Alamofire

class IvaController {    
    func next() {
        AF.request("http://192.168.0.101:8080", method: .post).response { data in
            print(data)
        }
    }
}
