import Foundation
import Testing
@testable import WhatToEat

struct MealsViewModelConcurrencyTests {
    @MainActor
    @Test
    func openResultsForSuggestionNavigatesImmediatelyWithoutNetworkFetch() async {
        let filterSpy = FilterMealsUseCaseSpy()
        let viewModel = makeMealsViewModel(filterSpy: filterSpy)

        viewModel.changeMode(to: .category)
        await waitForSuggestions(viewModel, mode: .category)
        viewModel.openResultsForSuggestion("Seafood")

        #expect(viewModel.selectedFilterRoute?.mode == .category)
        #expect(viewModel.selectedFilterRoute?.value == "Seafood")
        let filterCalls = await filterSpy.callCount
        #expect(filterCalls == 0)
    }

    @MainActor
    @Test
    func fetchFilteredMealsUsesRouteFilter() async throws {
        let filterSpy = FilterMealsUseCaseSpy(result: [
            FilteredMeal(idMeal: "1", strMeal: "A", strMealThumb: nil)
        ])
        let viewModel = makeMealsViewModel(filterSpy: filterSpy)
        let route = FilterResultsRoute(mode: .category, value: "Seafood")

        let result = try await viewModel.fetchFilteredMeals(for: route)

        #expect(result.count == 1)
        let captured = await filterSpy.filters
        #expect(captured.count == 1)
        if case .category(let value)? = captured.first {
            #expect(value == "Seafood")
        } else {
            Issue.record("Expected .category filter")
        }
    }

    @MainActor
    @Test
    func changeModeCachesLoadedFilterValues() async {
        let listSpy = GetMealListItemsUseCaseSpy()
        let viewModel = makeMealsViewModel(listSpy: listSpy)

        viewModel.changeMode(to: .category)
        await waitForSuggestions(viewModel, mode: .category)
        viewModel.changeMode(to: .area)
        await waitForSuggestions(viewModel, mode: .area)
        viewModel.changeMode(to: .category)
        try? await Task.sleep(for: .milliseconds(50))

        let counts = await listSpy.callCountByType
        #expect(counts[.category] == 1)
        #expect(counts[.area] == 1)
    }

    @MainActor
    @Test
    func nonNameSearchFiltersSuggestionsLocally() async {
        let viewModel = makeMealsViewModel()

        viewModel.changeMode(to: .category)
        await waitForSuggestions(viewModel, mode: .category)
        viewModel.setSearchText("sea", for: .category)

        let filtered = viewModel.filteredSuggestions(for: .category)

        #expect(filtered == ["Seafood"])
    }
}

struct MealDetailsViewModelConcurrencyTests {
    @MainActor
    @Test
    func concurrentToggleFavoritePerformsSingleMutation() async {
        let store = FavoritesStoreSpy(delayNanoseconds: 120_000_000)
        let viewModel = MealDetailsViewModel(meal: MockData.randomMeals[0], favoritesMealStore: store)

        async let first = viewModel.toggleFavorite()
        async let second = viewModel.toggleFavorite()
        _ = await (first, second)

        let addCalls = await store.addCallCount
        let removeCalls = await store.removeCallCount
        #expect(addCalls == 1)
        #expect(removeCalls == 0)
        #expect(viewModel.isFavorite)
    }
}

private extension MealsViewModelConcurrencyTests {
    @MainActor
    func makeMealsViewModel(
        searchSpy: SearchMealsUseCaseSpy = SearchMealsUseCaseSpy(),
        listSpy: GetMealListItemsUseCaseSpy = GetMealListItemsUseCaseSpy(),
        filterSpy: FilterMealsUseCaseSpy = FilterMealsUseCaseSpy(),
        lookupSpy: LookupMealByIDUseCaseSpy = LookupMealByIDUseCaseSpy()
    ) -> MealsViewModel {
        MealsViewModel(
            searchMealsUseCase: searchSpy,
            getMealListItemsUseCase: listSpy,
            filterMealsUseCase: filterSpy,
            lookupMealByIDUseCase: lookupSpy
        )
    }

    @MainActor
    func waitForSuggestions(_ viewModel: MealsViewModel, mode: MealsFilterMode) async {
        for _ in 0..<80 {
            if !viewModel.suggestions(for: mode).isEmpty {
                return
            }
            try? await Task.sleep(for: .milliseconds(20))
        }
        Issue.record("Timed out waiting for suggestions for \(mode)")
    }
}

private struct SearchMealsUseCaseSpy: SearchMealsUseCase {
    var result: [Meal] = MockData.randomMeals

    func execute(query: String) async throws -> [Meal] {
        result.filter { $0.strMeal.localizedCaseInsensitiveContains(query) }
    }
}

private actor GetMealListItemsUseCaseSpy: GetMealListItemsUseCase {
    private(set) var callCountByType: [MealListType: Int] = [:]

    func execute(type: MealListType) async throws -> MealListItems {
        callCountByType[type, default: 0] += 1
        switch type {
        case .category:
            return .categories(["Seafood", "Vegetarian"])
        case .area:
            return .areas(["Italian", "British"])
        case .ingredient:
            return .ingredients([Ingredient(idIngredient: "1", strIngredient: "Olive Oil", strDescription: nil, strType: nil)])
        }
    }
}

private actor FilterMealsUseCaseSpy: FilterMealsUseCase {
    private(set) var filters: [MealFilter] = []
    private let result: [FilteredMeal]

    init(result: [FilteredMeal] = []) {
        self.result = result
    }

    var callCount: Int { filters.count }

    func execute(filter: MealFilter) async throws -> [FilteredMeal] {
        filters.append(filter)
        return result
    }
}

private struct LookupMealByIDUseCaseSpy: LookupMealByIDUseCase {
    func execute(id: String) async throws -> Meal? {
        MockData.randomMeals.first { $0.idMeal == id }
    }
}

private actor FavoritesStoreSpy: FavoritesMealStore {
    private(set) var favorites: [String: Meal] = [:]
    private(set) var addCallCount = 0
    private(set) var removeCallCount = 0
    private let delayNanoseconds: UInt64

    init(delayNanoseconds: UInt64) {
        self.delayNanoseconds = delayNanoseconds
    }

    func fetchFavorites() async throws -> [Meal] {
        Array(favorites.values)
    }

    func addToFavorites(_ meal: Meal) async throws {
        addCallCount += 1
        try await Task.sleep(nanoseconds: delayNanoseconds)
        favorites[meal.idMeal] = meal
    }

    func removeFromFavorites(idMeal: String) async throws {
        removeCallCount += 1
        try await Task.sleep(nanoseconds: delayNanoseconds)
        favorites.removeValue(forKey: idMeal)
    }

    func reorderFavorites(from source: IndexSet, to destination: Int) async throws -> [Meal] {
        Array(favorites.values)
    }

    func isFavorite(idMeal: String) async throws -> Bool {
        favorites[idMeal] != nil
    }
}
