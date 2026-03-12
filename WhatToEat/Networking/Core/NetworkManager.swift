import Foundation

struct NetworkManager {
    static let shared = NetworkManager()

    private let baseURL: URL
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        baseURL: URL = URL(string: "https://www.themealdb.com/api/json/v1/1")!,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    func get<T: Decodable>(
        _ path: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> T {
        var request = try buildRequest(
            method: "GET",
            path: path,
            queryItems: queryItems
        )
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return try await execute(request, as: T.self)
    }

    func put<Body: Encodable, Response: Decodable>(
        _ path: String,
        body: Body,
        queryItems: [URLQueryItem] = []
    ) async throws -> Response {
        var request = try buildRequest(
            method: "PUT",
            path: path,
            queryItems: queryItems
        )
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        return try await execute(request, as: Response.self)
    }

    func update<Body: Encodable, Response: Decodable>(
        _ path: String,
        body: Body,
        queryItems: [URLQueryItem] = []
    ) async throws -> Response {
        var request = try buildRequest(
            method: "PATCH",
            path: path,
            queryItems: queryItems
        )
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        return try await execute(request, as: Response.self)
    }

    func delete<T: Decodable>(
        _ path: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> T {
        var request = try buildRequest(
            method: "DELETE",
            path: path,
            queryItems: queryItems
        )
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return try await execute(request, as: T.self)
    }

    func delete(
        _ path: String,
        queryItems: [URLQueryItem] = []
    ) async throws {
        var request = try buildRequest(
            method: "DELETE",
            path: path,
            queryItems: queryItems
        )
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        _ = try await execute(request, as: EmptyResponse.self)
    }

    private func buildRequest(
        method: String,
        path: String,
        queryItems: [URLQueryItem]
    ) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            throw CustomError.invalidURL
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw CustomError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        return request
    }

    private func execute<T: Decodable>(
        _ request: URLRequest,
        as type: T.Type
    ) async throws -> T {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CustomError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw CustomError.invalidResponse
        }

        if data.isEmpty, let empty = EmptyResponse() as? T {
            return empty
        }

        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw CustomError.invalidData
        }
    }
}
