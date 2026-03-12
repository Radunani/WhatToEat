import SwiftUI

struct ContentView: View {
    private let container: AppContainerProtocol

    init(container: AppContainerProtocol) {
        self.container = container
    }

    var body: some View {
        TabBarView(container: container)
    }
}
