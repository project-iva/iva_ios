//
//  BodyMassReporter.swift
//  iva_ios
//
//  Created by Igor Pidik on 15/07/2021.
//

import Foundation
import HealthKitReporter
import HealthKit
import Alamofire
import PromiseKit

class BodyMassReporter: ModelReporter<BodyMass, QuantityType> {
    func start() {
        retrieveLastStoredModelRecord().done { lastStoredBodyMass in
            self.lastStoredModel = lastStoredBodyMass
            self.startObserver(for: QuantityType.bodyMass)
        }.catch { error in
            print(error)
        }
    }
    
    override func handleUpdate(for type: QuantityType, _ predicate: NSPredicate? = nil) -> Guarantee<()> {
        return Guarantee<()> { seal in
            do {
                var startDatePredicate: NSPredicate?
                if let lastStoredBodyMass = self.lastStoredModel {
                    startDatePredicate = HKQuery.predicateForSamples(withStart: lastStoredBodyMass.start,
                                                                     end: nil, options: .strictStartDate)
                }
                let unit = HKUnit.gramUnit(with: .kilo)
                let readQuery = try self.reporter.reader.quantityQuery(type: type, unit: unit.unitString, predicate: startDatePredicate) { results, _ in
                    // Map results to BodyMass objects
                    var bodyMasses = results.map { BodyMass(quantity: $0) }
                    // HealthKit returns the latest entries first, therefore we reverse the order to get
                    // the oldest unsynced data first
                    bodyMasses.reverse()
                    self.syncModels(models: bodyMasses).done { () in
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
