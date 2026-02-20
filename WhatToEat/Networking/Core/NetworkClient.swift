import Foundation

protocol NetworkClient {
    func get<T: Decodable>(
        _ path: String,
        queryItems: [URLQueryItem]
    ) async throws -> T
}

extension NetworkManager: NetworkClient {}
