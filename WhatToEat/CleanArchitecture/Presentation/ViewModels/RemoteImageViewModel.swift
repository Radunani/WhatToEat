import SwiftUI
import Observation
import ImageIO

@MainActor
@Observable
final class RemoteImageViewModel {
    private(set) var image: Image?

    @ObservationIgnored
    private let imageDataLoader: ImageDataLoader
    @ObservationIgnored
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
                guard !Task.isCancelled else {
                    return
                }

                let cgImage = await Self.decodeImage(from: data)
                guard !Task.isCancelled,
                      let cgImage else {
                    return
                }
                image = Image(decorative: cgImage, scale: 1, orientation: .up)
            } catch {
                image = nil
            }
        }
    }

    nonisolated private static func decodeImage(from data: Data) async -> CGImage? {
        await Task.detached(priority: .userInitiated) {
            guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
                return nil
            }

            return CGImageSourceCreateImageAtIndex(
                source,
                0,
                [kCGImageSourceShouldCache: false] as CFDictionary
            )
        }.value
    }
}
