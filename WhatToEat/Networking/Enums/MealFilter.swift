import Foundation

enum MealFilter {
    case ingredient(String)
    case category(String)
    case area(String)

    var queryItem: URLQueryItem {
        switch self {
        case .ingredient(let value):
            return URLQueryItem(name: "i", value: value)
        case .category(let value):
            return URLQueryItem(name: "c", value: value)
        case .area(let value):
            return URLQueryItem(name: "a", value: value)
        }
    }
}
