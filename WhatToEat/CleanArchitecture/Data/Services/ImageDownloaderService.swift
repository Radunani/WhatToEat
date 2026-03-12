import Foundation

protocol URLSessionDataFetching: Sendable {
    func data(from url: URL) async throws -> (Data, URLResponse)
}
