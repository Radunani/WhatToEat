import Foundation

extension Meal {
    private static let websiteBaseURL = URL(string: "https://www.themealdb.com")!

    func thumbnailURL(size: MealThumbnailSize) -> URL? {
        guard let strMealThumb else { return nil }

        let baseURL: URL
        if let url = URL(string: strMealThumb), url.scheme != nil {
            baseURL = url
        } else {
            let normalizedPath = strMealThumb.hasPrefix("/") ? String(strMealThumb.dropFirst()) : strMealThumb
            baseURL = Self.websiteBaseURL.appendingPathComponent(normalizedPath)
        }

        return baseURL.appendingPathComponent(size.rawValue)
    }

    var displayTags: [String] {
        [strArea, strCategory]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
