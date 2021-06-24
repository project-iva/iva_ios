//
//  MindfulSessionReporter.swift
//  iva_ios
//
//  Created by Igor Pidik on 24/06/2021.
//

import Foundation
import HealthKitReporter
import HealthKit

class MindfulSessionReporter: ModelReporter<MindfulSession> {
    
    func start() {
        retrieveLastStoredModelRecord().done { lastStoredMindfulSession in
            self.lastStoredModel = lastStoredMindfulSession
            self.startObserver()
        }.catch { error in
            print(error)
        }
    }
    
    private func startObserver() {
        let type = CategoryType.mindfulSession
        do {
            let query = try reporter.observer.observerQuery(
                type: type
            ) { (_, identifier, error) in
                if error == nil && identifier != nil {
                    print("updates for \(identifier!)")
                    
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
                            self.syncModels(models: mindfulSessions)
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
}