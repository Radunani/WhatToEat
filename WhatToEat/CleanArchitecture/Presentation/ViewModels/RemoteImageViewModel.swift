import SwiftUI
import UIKit

@MainActor
final class RemoteImageViewModel: ObservableObject {
    @Published private(set) var image: Image?

    private let imageDataLoader: ImageDataLoader
    private var loadTask: Task<Void, Never>?

    init(imageDataLoader: ImageDataLoader = ImageDownloaderService.shared) {
        self.imageDataLoader = imageDataLoader
    }

    deinit {
        loadTask?.cancel()
    }

    func load(from url: URL?) {
        guard let url else {
            image = nil
            return
        }

        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }

            do {
                let data = try await imageDataLoader.loadImageData(from: url)
                guard !Task.isCancelled,
                      let uiImage = UIImage(data: data) else {
                    return
                }
                image = Image(uiImage: uiImage)
            } catch {
                image = nil
            }
        }
    }
}
