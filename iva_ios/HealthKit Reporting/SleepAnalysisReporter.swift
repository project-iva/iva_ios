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

enum SleepAnalysisError: Error {
    case failedToRetrieveSleepAnalysisType
    case failedToRetrieveSources
    case failedToRetrieveAutoSleepSource
}

class SleepAnalysisReporter: ModelReporter<SleepAnalysis, CategoryType> {
    
    func start() {
        firstly {
            when(fulfilled: retrieveLastStoredModelRecord(), retrieveAutoSleepSource())
        }.done { lastStoredSleepAnalysis, source in
            self.lastStoredModel = lastStoredSleepAnalysis
            let autoSleepPredicate = HKQuery.predicateForObjects(from: [source])
            self.startObserver(for: CategoryType.sleepAnalysis, autoSleepPredicate)
        }.catch { error in
            print(error)
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
    
    override func handleUpdate(for type: CategoryType, _ predicate: NSPredicate? = nil) -> Guarantee<()> {
        return Guarantee<()> { seal in
            do {
                var predicates: [NSPredicate] = []
                if let predicate = predicate {
                    predicates.append(predicate)
                }
                
                if let lastStoredAnalysis = self.lastStoredModel {
                    let startDatePredicate = HKQuery.predicateForSamples(withStart: lastStoredAnalysis.start,
                                                                         end: nil, options: .strictStartDate)
                    predicates.append(startDatePredicate)
                }
                
                let compoundPredicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: predicates)
                let readQuery = try self.reporter.reader.categoryQuery(type: type, predicate: compoundPredicate) { results, _ in
                    // Map results to SleepAnalysis objects
                    var sleepAnalyses = results.map { SleepAnalysis(category: $0) }
                    // HealthKit returns the latest entries first, therefore we reverse the order to get
                    // the oldest unsynced data first
                    sleepAnalyses.reverse()
                    
                    self.syncModels(models: sleepAnalyses).done { _ in
                        seal(())
                    }
                }
                self.reporter.manager.executeQuery(readQuery)
            } catch {
                print("error reading query")
                seal(())
            }
        }
    }
}
