//
//  SleepAnalysisReporter.swift
//  iva_ios
//
//  Created by Igor Pidik on 23/06/2021.
//

import Foundation
import HealthKitReporter
import HealthKit
import PromiseKit
import AwaitKit

enum SleepAnalysisError: Error {
    case failedToRetrieveSleepAnalysisType
    case failedToRetrieveSources
    case failedToRetrieveAutoSleepSource
    // Contains last successfully posted SleepAnalysis if there is one
    case failedToPostSleepAnalyses(SleepAnalysis?)
}

class SleepAnalysisReporter {
    private let reporter: HealthKitReporter
    private var lastStoredSleepAnalysis: SleepAnalysis?
    
    init(reporter: HealthKitReporter) {
        self.reporter = reporter
    }
    
    func start() {
        firstly {
            when(fulfilled: retrieveLastStoredSleepRecord(), retrieveAutoSleepSource())
        }.done { lastStoredSleepAnalysis, source in
            self.lastStoredSleepAnalysis = lastStoredSleepAnalysis
            self.startObserver(autoSleepSource: source)
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
    
    private func startObserver(autoSleepSource: HKSource) {
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
                        var predicates: [NSPredicate] = [autoSleepPredicate]
                        if let lastStoredAnalysis = self.lastStoredSleepAnalysis {
                            let startDatePredicate = HKQuery.predicateForSamples(withStart: lastStoredAnalysis.start,
                                                                                 end: nil, options: .strictStartDate)
                            predicates.append(startDatePredicate)
                        }
                        
                        let compoundPredicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: predicates)
                        let readQuery = try self.reporter.reader.categoryQuery(type: type,predicate: compoundPredicate) { results, _ in
                            // Map results to SleepAnalysis objects
                            var sleepAnalyses = results.map { SleepAnalysis(category: $0) }
                            // HealthKit returns the latest entries first, therefore we reverse the order to get
                            // the oldest unsynced data first
                            sleepAnalyses.reverse()
                            
                            self.syncSleepAnalyses(sleepAnalyses: sleepAnalyses)
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
    
    private func findNewSleepAnalyses(sleepAnalyses: [SleepAnalysis]) -> [SleepAnalysis] {
        if let lastStoredSleepAnalysis = self.lastStoredSleepAnalysis,
           let index = sleepAnalyses.firstIndex(where: { $0.uuid == lastStoredSleepAnalysis.uuid }) {
            return Array(sleepAnalyses.dropFirst(index + 1))
        }
        
        return sleepAnalyses
    }
    
    private func postNewSleepAnalyses(sleepAnalyses: [SleepAnalysis]) -> Promise<SleepAnalysis?> {
        return async {
            var lastSuccessfullyPostedSleepAnalysis: SleepAnalysis?
            for sleepAnalysis in sleepAnalyses {
                do {
                    let response = try `await`(
                        ApiHandler.shared.makeRequest(
                            request: ModelViewSetRouter<SleepAnalysis>.post(sleepAnalysis),
                            resultType: SleepAnalysis.self)
                    )
                    lastSuccessfullyPostedSleepAnalysis = response.result
                } catch {
                    throw SleepAnalysisError.failedToPostSleepAnalyses(lastSuccessfullyPostedSleepAnalysis)
                }
            }
            
            return lastSuccessfullyPostedSleepAnalysis
        }
    }
    
    private func syncSleepAnalyses(sleepAnalyses: [SleepAnalysis]) {
        let sleepAnalysesToSync = findNewSleepAnalyses(sleepAnalyses: sleepAnalyses)
        postNewSleepAnalyses(sleepAnalyses: sleepAnalysesToSync).done { lastSuccessfullyPostedSleepAnalysis in
            self.lastStoredSleepAnalysis = lastSuccessfullyPostedSleepAnalysis ?? self.lastStoredSleepAnalysis
        }.catch { error in
            if let error = error as? SleepAnalysisError,
               case let SleepAnalysisError.failedToPostSleepAnalyses(lastSuccessfullyPostedSleepAnalysis) = error {
                self.lastStoredSleepAnalysis = lastSuccessfullyPostedSleepAnalysis ?? self.lastStoredSleepAnalysis
            }
        }
    }
}
