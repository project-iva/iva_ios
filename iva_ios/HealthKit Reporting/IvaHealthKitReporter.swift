//
//  IvaHealthKitReporter.swift
//  iva_ios
//
//  Created by Igor Pidik on 20/06/2021.
//

import Foundation
import HealthKitReporter
import HealthKit
import PromiseKit

class IvaHealthKitReporter {
    private let reporter: HealthKitReporter
    private let sleepAnalysisReporter: SleepAnalysisReporter
    private let mindfulSessionReporter: MindfulSessionReporter
    
    init(reporter: HealthKitReporter) {
        self.reporter = reporter
        self.sleepAnalysisReporter = SleepAnalysisReporter(reporter: reporter)
        self.mindfulSessionReporter = MindfulSessionReporter(reporter: reporter)
    }
    
    func start() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        let types = [
            CategoryType.mindfulSession,
            CategoryType.sleepAnalysis
        ]
        
        reporter.manager.requestAuthorization(
            toRead: types,
            toWrite: []
        ) {(success, error) in
            if success && error == nil {
                self.sleepAnalysisReporter.start()
                self.mindfulSessionReporter.start()
            } else {
                print(error)
            }
        }
    }
}
