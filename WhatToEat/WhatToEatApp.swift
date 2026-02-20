import SwiftUI

@main
struct WhatToEatApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            TabBarView(container: container)
        }
    }
}
