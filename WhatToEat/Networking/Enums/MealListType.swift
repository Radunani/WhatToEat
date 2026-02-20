import Foundation

enum MealListType {
    case category
    case area
    case ingredient

    var queryKey: String {
        switch self {
        case .category:
            return "c"
        case .area:
            return "a"
        case .ingredient:
            return "i"
        }
    }
}
