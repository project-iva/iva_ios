//
//  ModelReporter.swift
//  iva_ios
//
//  Created by Igor Pidik on 24/06/2021.
//

import Foundation
import HealthKitReporter
import HealthKit
import PromiseKit
import AwaitKit

class ModelReporter<Model: Codable & ModelWithStartTimeAndUUID, HealthKitSampleType: SampleType> {
    enum ModelSyncError: Error {
        case failedToSyncModels(Model?)
    }
    
    let reporter: HealthKitReporter
    var lastStoredModel: Model?
    private let queue = DispatchQueue(label: "com.iva.healthkit.updatequeue")
    
    init(reporter: HealthKitReporter) {
        self.reporter = reporter
    }
    
    func retrieveLastStoredModelRecord() -> Promise<Model?> {
        return Promise<Model?> { seal in
            ApiHandler.shared.makeRequest(request: ModelViewSetRouter<Model>.get(1),
                                          resultType: [Model].self).done { response in
                                            seal.fulfill(response.result.first)
                                          }.catch { error in
                                            seal.reject(error)
                                          }
        }
    }
    
    func startObserver(for type: HealthKitSampleType, _ predicate: NSPredicate? = nil) {
        do {
            let query = try reporter.observer.observerQuery(
                type: type,
                predicate: predicate
            ) { (_, identifier, error) in
                if error == nil && identifier != nil {
                    self.queue.async {
                        print("update started for \(identifier)")
                        let semaphore = DispatchSemaphore(value: 0)
                        self.handleUpdate(for: type, predicate).done { _ in
                            semaphore.signal()
                        }
                        semaphore.wait()
                        print("update finished for \(identifier)")
                    }
                }
            }
            
            reporter.observer.enableBackgroundDelivery(
                type: type,
                frequency: .immediate
            ) { (_, error) in
                if error == nil {
                    print("background delivery enabled")
                }
            }
            reporter.manager.executeQuery(query)
        } catch {
            print(error)
        }
    }
    
    func handleUpdate(for type: HealthKitSampleType, _ predicate: NSPredicate? = nil) -> Guarantee<()> {
        fatalError("this method must be overriden")
    }
    
    private func findUnsyncedModels(models: [Model]) -> [Model] {
        if let lastStoredModel = self.lastStoredModel,
           let index = models.firstIndex(where: { $0.uuid == lastStoredModel.uuid }) {
            return Array(models.dropFirst(index + 1))
        }
        
        return models
    }
    
    private func postUnsyncedModels(models: [Model]) -> Promise<Model?> {
        return async {
            var lastSuccessfullyPostedModel: Model?
            for model in models {
                do {
                    let response = try `await`(
                        ApiHandler.shared.makeRequest(
                            request: ModelViewSetRouter<Model>.post(model),
                            resultType: Model.self)
                    )
                    lastSuccessfullyPostedModel = response.result
                } catch {
                    throw ModelSyncError.failedToSyncModels(lastSuccessfullyPostedModel)
                }
            }
            
            return lastSuccessfullyPostedModel
        }
    }
    
    func syncModels(models: [Model]) -> Guarantee<()> {
        return Guarantee<()> { seal in
            let modelsToSync = findUnsyncedModels(models: models)
            postUnsyncedModels(models: modelsToSync).done { lastSuccessfullyPostedModel in
                self.lastStoredModel = lastSuccessfullyPostedModel ?? self.lastStoredModel
            }.catch { error in
                if let error = error as? ModelSyncError,
                   case let ModelSyncError.failedToSyncModels(lastSuccessfullyPostedModel) = error {
                    self.lastStoredModel = lastSuccessfullyPostedModel ?? self.lastStoredModel
                }
            }.finally {
                seal(())
            }
        }
    }
}
