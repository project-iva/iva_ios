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

class ModelReporter<Model: Codable & ModelWithStartTimeAndUUID> {
    
    enum ModelSyncError: Error {
        case failedToSyncModels(Model?)
    }
    
    let reporter: HealthKitReporter
    var lastStoredModel: Model?
    
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
    
    func syncModels(models: [Model]) {
        let modelsToSync = findUnsyncedModels(models: models)
        postUnsyncedModels(models: modelsToSync).done { lastSuccessfullyPostedModel in
            self.lastStoredModel = lastSuccessfullyPostedModel ?? self.lastStoredModel
        }.catch { error in
            if let error = error as? ModelSyncError,
               case let ModelSyncError.failedToSyncModels(lastSuccessfullyPostedModel) = error {
                self.lastStoredModel = lastSuccessfullyPostedModel ?? self.lastStoredModel
            }
        }
    }
}
