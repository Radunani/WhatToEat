import Foundation
import Observation

@MainActor
@Observable
final class FilterSuggestionsPageViewModel {
    let mode: MealsFilterMode

    var query: String
    private(set) var suggestions: [String]
    private(set) var isLoading = false

    @ObservationIgnored
    private let executeListItems: @MainActor (MealListType) async throws -> MealListItems
    @ObservationIgnored
    private var hasLoaded = false
    @ObservationIgnored
    private var requestID = UUID()

    init(
        mode: MealsFilterMode,
        getMealListItemsUseCase: GetMealListItemsUseCase,
        initialQuery: String = "",
        initialSuggestions: [String] = []
    ) {
        self.mode = mode
        self.executeListItems = { type in
            try await getMealListItemsUseCase.execute(type: type)
        }
        self.query = initialQuery
        self.suggestions = initialSuggestions
        self.hasLoaded = !initialSuggestions.isEmpty
    }

    init(
        mode: MealsFilterMode,
        executeListItems: @escaping @MainActor (MealListType) async throws -> MealListItems,
        initialQuery: String = "",
        initialSuggestions: [String] = []
    ) {
        self.mode = mode
        self.executeListItems = executeListItems
        self.query = initialQuery
        self.suggestions = initialSuggestions
        self.hasLoaded = !initialSuggestions.isEmpty
    }

    var filteredSuggestions: [String] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return suggestions }
        return suggestions.filter { $0.localizedStandardContains(trimmedQuery) }
    }

    var ingredientSuggestionSections: [SuggestionSection] {
        guard mode == .ingredient else { return [] }

        let grouped = Dictionary(grouping: filteredSuggestions) { value in
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.first.map { String($0).uppercased() } ?? "#"
        }

        return grouped
            .map { SuggestionSection(title: $0.key, items: $0.value.sorted()) }
            .sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        await loadSuggestions(force: false)
    }

    func refresh() async {
        await loadSuggestions(force: true)
    }

    private func loadSuggestions(force: Bool) async {
        guard mode != .name else { return }
        guard let listType = mode.listType else {
            suggestions = []
            return
        }
        if !force, hasLoaded { return }

        let currentRequestID = UUID()
        requestID = currentRequestID
        isLoading = true
        defer {
            if requestID == currentRequestID {
                isLoading = false
            }
        }

        do {
            let items = try await executeListItems(listType)
            guard requestID == currentRequestID else { return }
            suggestions = Self.values(from: items)
            hasLoaded = true
        } catch is CancellationError {
            return
        } catch {
            guard requestID == currentRequestID else { return }
            suggestions = []
            hasLoaded = true
        }
    }

    private static func values(from items: MealListItems) -> [String] {
        switch items {
        case .categories(let values):
            return values.sorted()
        case .areas(let values):
            return values.sorted()
        case .ingredients(let values):
            return values.map(\.strIngredient).sorted()
        }
    }
}
