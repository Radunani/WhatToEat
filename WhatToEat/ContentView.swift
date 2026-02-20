import SwiftUI

struct ContentView: View {
    private let container = AppContainer()

    var body: some View {
        TabBarView(container: container)
    }
}

#Preview {
    ContentView()
}
