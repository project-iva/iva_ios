//
//  MindfulSessionReporter.swift
//  iva_ios
//
//  Created by Igor Pidik on 24/06/2021.
//

import Foundation
import HealthKitReporter
import HealthKit
import Alamofire
import PromiseKit

class MindfulSessionReporter: ModelReporter<MindfulSession> {
    func start() {
        retrieveLastStoredModelRecord().done { lastStoredMindfulSession in
            self.lastStoredModel = lastStoredMindfulSession
            self.startObserver(for: CategoryType.mindfulSession)
        }.catch { error in
            print(error)
        }
    }
    
    override func handleUpdate(for type: CategoryType, _ predicate: NSPredicate? = nil) -> Guarantee<()> {
        return Guarantee<()> { seal in
            do {
                var startDatePredicate: NSPredicate?
                if let lastStoredMindfulSession = self.lastStoredModel {
                    startDatePredicate = HKQuery.predicateForSamples(withStart: lastStoredMindfulSession.start,
                                                                     end: nil, options: .strictStartDate)
                }
                
                let readQuery = try self.reporter.reader.categoryQuery(type: type, predicate: startDatePredicate) { results, _ in
                    // Map results to MindfulSession objects
                    var mindfulSessions = results.map { MindfulSession(category: $0) }
                    // HealthKit returns the latest entries first, therefore we reverse the order to get
                    // the oldest unsynced data first
                    mindfulSessions.reverse()
                    self.syncModels(models: mindfulSessions).done { () in
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
