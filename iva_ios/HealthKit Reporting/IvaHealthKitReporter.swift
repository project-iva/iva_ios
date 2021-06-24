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
    
    init(reporter: HealthKitReporter) {
        self.reporter = reporter
        self.sleepAnalysisReporter = SleepAnalysisReporter(reporter: reporter)
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
            } else {
                print(error)
            }
        }
    }
        
    private func startMeditationObserver() {
        do {
            let reporter = try HealthKitReporter()
            let type = CategoryType.mindfulSession
            
            reporter.manager.requestAuthorization(
                toRead: [type],
                toWrite: [type]
            ) { (success, error) in
                if success && error == nil {
                    do {
                        // Create observer
                        let observerQuery = try reporter.observer.observerQuery(
                            type: type
                        ) { (_, identifier, error) in
                            if error == nil && identifier != nil {
                                print("updates for \(identifier!)")
                                // Read data
                                do {
                                    let readQuery = try reporter.reader.categoryQuery(type: type, limit: 6) { _, _ in
                                    }
                                    reporter.manager.executeQuery(readQuery)
                                } catch {
                                    print("error")
                                }
                            }
                        }
                        reporter.observer.enableBackgroundDelivery(
                            type: type,
                            frequency: .immediate
                        ) { (_, error) in
                            if error == nil {
                                print("enabled")
                            }
                        }
                        reporter.manager.executeQuery(observerQuery)
                    } catch {
                        print(error)
                    }
                    
                } else {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
}
