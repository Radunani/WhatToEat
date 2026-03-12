import Foundation

enum MealsFilterMode: String, CaseIterable, Identifiable {
    case name, category, area, ingredient

    var id: String { rawValue }

    var title: String {
        switch self {
        case .name: "mode.name.title".localized
        case .category: "mode.category.title".localized
        case .area: "mode.area.title".localized
        case .ingredient: "mode.ingredient.title".localized
        }
    }

    var placeholder: String {
        switch self {
        case .name: "mode.name.placeholder".localized
        case .category: "mode.category.placeholder".localized
        case .area: "mode.area.placeholder".localized
        case .ingredient: "mode.ingredient.placeholder".localized
        }
    }

    var searchPrompt: String {
        switch self {
        case .name: "mode.name.search_prompt".localized
        case .category: "mode.category.search_prompt".localized
        case .area: "mode.area.search_prompt".localized
        case .ingredient: "mode.ingredient.search_prompt".localized
        }
    }

    var listType: MealListType? {
        switch self {
        case .name: nil
        case .category: .category
        case .area: .area
        case .ingredient: .ingredient
        }
    }

    func makeFilter(with value: String) -> MealFilter? {
        switch self {
        case .name: nil
        case .category: .category(value)
        case .area: .area(value)
        case .ingredient: .ingredient(value)
        }
    }
}
