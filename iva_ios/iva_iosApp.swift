//
//  iva_iosApp.swift
//  iva_ios
//
//  Created by Igor Pidik on 07/05/2021.
//

import SwiftUI
import HealthKitReporter
import PromiseKit

@main
// swiftlint:disable:next type_name
struct iva_iosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private let reporter = try? HealthKitReporter()

    init() {
        if let reporter = try? HealthKitReporter() {
            let ivaReporter = IvaHealthKitReporter(reporter: reporter)
            ivaReporter.start()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
