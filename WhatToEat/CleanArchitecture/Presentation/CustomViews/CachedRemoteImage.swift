import SwiftUI

@MainActor
struct CachedRemoteImage: View {
    @State private var viewModel: RemoteImageViewModel
    private let url: URL?

    init(url: URL?, viewModel: RemoteImageViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? RemoteImageViewModel())
        self.url = url
    }

    var body: some View {
        Group {
            if let image = viewModel.image {
                image
                    .resizable()
            } else {
                Image(.placeholder)
                    .resizable()
            }
        }
        .task(id: url) {
            viewModel.load(from: url)
        }
    }
}
