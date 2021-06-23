//
//  iva_iosApp.swift
//  iva_watch Extension
//
//  Created by Igor Pidik on 10/05/2021.
//

import SwiftUI

@main
// swiftlint:disable:next type_name
struct iva_iosApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
