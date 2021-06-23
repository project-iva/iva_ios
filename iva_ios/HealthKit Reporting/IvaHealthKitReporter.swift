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

enum SleepAnalysisError: Error {
    case failedToRetrieveSleepAnalysisType
    case failedToRetrieveSources
    case failedToRetrieveAutoSleepSource
}

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
        firstly {
            when(fulfilled: retrieveLastStoredSleepRecord(), retrieveAutoSleepSource())
        }.done { lastStoredRecord, source in
            print(lastStoredRecord)
            print(source)
            self.startSleepAnalysisObserver(autoSleepSource: source, lastStoredAnalysis: lastStoredRecord!)
        }.catch { error in
            print(error)
        }
    }
    
    private func retrieveLastStoredSleepRecord() -> Promise<SleepAnalysis?> {
        return Promise<SleepAnalysis?> { seal in
            ApiHandler.shared.makeRequest(request: ModelViewSetRouter<SleepAnalysis>.get(1),
                                          resultType: [SleepAnalysis].self).done { response in
                                            seal.fulfill(response.result.first)
                                          }.catch { error in
                                            seal.reject(error)
                                          }
        }
    }
    
    private func retrieveAutoSleepSource() -> Promise<HKSource> {
        return Promise<HKSource> { seal in
            guard let sleepAnalysisType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
                // This should never fail when using a defined constant.
                seal.reject(SleepAnalysisError.failedToRetrieveSleepAnalysisType)
                return
            }
            
            let query = HKSourceQuery(sampleType: sleepAnalysisType, samplePredicate: nil) {(_, sourcesOrNil, _) in
                
                guard let sources = sourcesOrNil else {
                    seal.reject(SleepAnalysisError.failedToRetrieveSources)
                    return
                }
                
                let autoSleepSources = sources.filter { source in
                    return source.name == "AutoSleep"
                }
                
                guard let autoSleepSource = autoSleepSources.first else {
                    seal.reject(SleepAnalysisError.failedToRetrieveAutoSleepSource)
                    return
                }
                
                seal.fulfill(autoSleepSource)
            }
            
            reporter.manager.executeQuery(query)
        }
    }
    
    private func startSleepAnalysisObserver(autoSleepSource: HKSource, lastStoredAnalysis: SleepAnalysis) {
        let type = CategoryType.sleepAnalysis
        let autoSleepPredicate = HKQuery.predicateForObjects(from: [autoSleepSource])
        do {
            let query = try reporter.observer.observerQuery(
                type: type,
                predicate: autoSleepPredicate
            ) { (_, identifier, error) in
                if error == nil && identifier != nil {
                    print("updates for \(identifier!)")
                    do {
                        print(HKPredicateKeyPathSource)
                        let startDatePredicate = HKQuery.predicateForSamples(withStart: lastStoredAnalysis.start, end: nil, options: .strictStartDate)
                        let combinedPredicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [autoSleepPredicate, startDatePredicate])
                        let readQuery = try self.reporter.reader.categoryQuery(type: type, predicate: combinedPredicate) { results, _ in
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
            ) { (_, error) in
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
