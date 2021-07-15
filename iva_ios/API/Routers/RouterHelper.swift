//
//  RouterHelper.swift
//  iva_ios
//
//  Created by Igor Pidik on 23/06/2021.
//

import Foundation

class RouterHelper {
    static func getEndpoint(for model: Any.Type) -> String {
        switch model {
            case is MindfulSession.Type:
                return "mindful-sessions/"
            
            case is SleepAnalysis.Type:
                return "sleep-analyses/"

            case is BodyMass.Type:
                return "body-masses/"

            default:
                fatalError("No endpoint defined for this model")
        }
    }
}
