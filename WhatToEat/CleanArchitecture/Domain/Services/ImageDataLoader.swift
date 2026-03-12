import Foundation

protocol ImageDataLoader: Sendable {
    func loadImageData(from url: URL) async throws -> Data
}
