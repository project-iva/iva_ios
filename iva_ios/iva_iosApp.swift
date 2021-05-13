//
//  iva_iosApp.swift
//  iva_ios
//
//  Created by Igor Pidik on 07/05/2021.
//

import SwiftUI
import HealthKitReporter
import Starscream

@main
struct iva_iosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
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
                        // Read data
                        let readQuery = try reporter.reader.categoryQuery(type: type) { results, error in
                            for element in results {
                                do {
                                    print(try element.encoded())
                                } catch {
                                    print(error)
                                }
                            }
                        }
                        reporter.manager.executeQuery(readQuery)
                        
                        // Create observer
                        let observerQuery = try reporter.observer.observerQuery(
                            type: type
                        ) { (query, identifier, error) in
                            if error == nil && identifier != nil {
                                print("updates for \(identifier!)")
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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
