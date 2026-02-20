import Foundation

enum MealDBEndpoint {
    case searchByName(String)
    case listByFirstLetter(Character)
    case lookupByID(String)
    case random
    case categories
    case list(MealListType)
    case filter(MealFilter)

    var path: String {
        switch self {
        case .searchByName:
            return "search.php"
        case .listByFirstLetter:
            return "search.php"
        case .lookupByID:
            return "lookup.php"
        case .random:
            return "random.php"
        case .categories:
            return "categories.php"
        case .list:
            return "list.php"
        case .filter:
            return "filter.php"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .searchByName(let name):
            return [URLQueryItem(name: "s", value: name)]
        case .listByFirstLetter(let letter):
            return [URLQueryItem(name: "f", value: String(letter))]
        case .lookupByID(let id):
            return [URLQueryItem(name: "i", value: id)]
        case .random:
            return []
        case .categories:
            return []
        case .list(let type):
            return [URLQueryItem(name: type.queryKey, value: "list")]
        case .filter(let filter):
            return [filter.queryItem]
        }
    }
}
