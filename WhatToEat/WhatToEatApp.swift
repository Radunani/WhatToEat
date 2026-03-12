import SwiftUI

@main
struct WhatToEatApp: App {
    private let container: AppContainerProtocol = AppContainer()

    var body: some Scene {
        WindowGroup {
            ContentView(container: container)
        }
    }
}
