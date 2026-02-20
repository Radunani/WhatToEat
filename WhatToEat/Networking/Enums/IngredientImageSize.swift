import Foundation

enum IngredientImageSize {
    case original
    case small
    case medium
    case large

    var suffix: String {
        switch self {
        case .original:
            return ""
        case .small:
            return "-small"
        case .medium:
            return "-medium"
        case .large:
            return "-large"
        }
    }
}
