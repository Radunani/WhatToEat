import Foundation

enum NoResultsContext {
    private static func format(_ key: String, with arguments: [String]) -> String {
        arguments.reduce(key.localized) { partial, argument in
            partial.replacing("%@", with: argument, maxReplacements: 1)
        }
    }

    static let mealsByName = NoResultsItem(
        title: "content.no_results.title".localized,
        systemImage: "fork.knife",
        message: "content.no_results.adjust_filter".localized
    )

    static let favorites = NoResultsItem(
        title: "content.no_favorites.title".localized,
        systemImage: "heart",
        message: "content.no_favorites.message".localized
    )

    static func suggestions(for mode: MealsFilterMode) -> NoResultsItem {
        NoResultsItem(
            title: "content.no_suggestions.title".localized,
            systemImage: "line.3.horizontal.decrease.circle",
            message: format("content.no_suggestions.for_mode", with: [mode.title])
        )
    }

    static func filteredMeals(for value: String) -> NoResultsItem {
        NoResultsItem(
            title: "content.no_results.title".localized,
            systemImage: "fork.knife",
            message: format("content.no_results.for_value", with: [value])
        )
    }

    static func error(_ message: String) -> NoResultsItem {
        NoResultsItem(
            title: "content.error.title".localized,
            systemImage: "exclamationmark.triangle",
            message: message
        )
    }
}
