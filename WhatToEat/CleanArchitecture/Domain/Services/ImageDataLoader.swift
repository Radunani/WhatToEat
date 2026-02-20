import Foundation

protocol ImageDataLoader {
    func loadImageData(from url: URL) async throws -> Data
}
