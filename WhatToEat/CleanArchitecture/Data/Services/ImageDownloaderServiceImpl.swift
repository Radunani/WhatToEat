import Foundation

actor ImageDownloaderService: ImageDataLoader {
    static let shared = ImageDownloaderService()

    private let session: URLSessionDataFetching
    private let cache = NSCache<NSURL, NSData>()

    init(session: URLSessionDataFetching = URLSessionDataFetcher()) {
        self.session = session
        cache.countLimit = 300
        cache.totalCostLimit = 100 * 1024 * 1024
    }

    func loadImageData(from url: URL) async throws -> Data {
        let key = url as NSURL

        if let cached = cache.object(forKey: key) {
            return cached as Data
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw CustomError.invalidResponse
        }

        guard !data.isEmpty else {
            throw CustomError.invalidData
        }

        cache.setObject(data as NSData, forKey: key, cost: data.count)
        return data
    }
}
