//
//  IvaHealthKitReporter.swift
//  iva_ios
//
//  Created by Igor Pidik on 20/06/2021.
//

import Foundation
import HealthKitReporter
import HealthKit


class IvaHealthKitReporter {
    private let reporter: HealthKitReporter
    
    init(reporter: HealthKitReporter) {
        self.reporter = reporter
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
                self.handleSleepAnalysis()
            } else {
                print(error)
            }
        }
    }
    
    private func handleSleepAnalysis() {
        guard let sleepAnalysisType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            // This should never fail when using a defined constant.
            fatalError("*** Unable to get the sleep analysis type ***")
        }
        let query = HKSourceQuery(sampleType: sleepAnalysisType, samplePredicate: nil) {(query, sourcesOrNil, errorOrNil) in
            
            guard let sources = sourcesOrNil else {
                // Properly handle the error.
                return
            }
            
            let autoSleepSources = sources.filter { source in
                return source.name == "AutoSleep"
            }
            
            if let autoSleepSource = autoSleepSources.first {
                self.startSleepAnalysisObserver(autoSleepSource: autoSleepSource)
            }
        }
        
        reporter.manager.executeQuery(query)
    }
    
    private func startSleepAnalysisObserver(autoSleepSource: HKSource) {
        let type = CategoryType.sleepAnalysis
        let autoSleepPredicate = HKQuery.predicateForObjects(from: [autoSleepSource])
        do {
            let query = try reporter.observer.observerQuery(
                type: type,
                predicate: autoSleepPredicate
            ) { (query, identifier, error) in
                if error == nil && identifier != nil {
                    print("updates for \(identifier!)")
                    do {
                        print(HKPredicateKeyPathSource)
                        let readQuery = try self.reporter.reader.categoryQuery(type: type, predicate: autoSleepPredicate, limit: 100) { results, error in
                            for result in results {
                                if let session = try? result.encoded() {
                                    print(Date(timeIntervalSince1970: result.startTimestamp))
                                    print(Date(timeIntervalSince1970: result.endTimestamp))
                                    print(session)
                                }
                            }
                        }
                        self.reporter.manager.executeQuery(readQuery)
                    } catch {
                        print("error")
                    }
                }
            }
            reporter.observer.enableBackgroundDelivery(
                type: type,
                frequency: .immediate
            ) { (success, error) in
                if error == nil {
                    print("enabled")
                }
            }
            reporter.manager.executeQuery(query)
        } catch {
            print(error)
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
                        ) { (query, identifier, error) in
                            if error == nil && identifier != nil {
                                print("updates for \(identifier!)")
                                // Read data
                                do {
                                    let readQuery = try reporter.reader.categoryQuery(type: type, limit: 1) { results, error in
                                        if let session = try? results.first?.encoded() {
                                            print(session)
                                        }
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
                        ) { (success, error) in
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
