import SwiftUI

@main
struct WhatToEatApp: App {
    private let container: AppContainerProtocol

    init() {
        if ProcessInfo.processInfo.arguments.contains("UI_TEST_MODE") {
            container = UITestAppContainer()
        } else {
            container = AppContainer()
        }
    }

    var body: some Scene {
        WindowGroup {
            TabBarView(container: container)
        }
    }
}
