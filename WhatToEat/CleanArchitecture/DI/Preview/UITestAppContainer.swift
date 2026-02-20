import Foundation

final class UITestAppContainer: AppContainerProtocol {
    private let favoritesMealStore: FavoritesMealStore
    private let randomMeals: [Meal]

    init() {
        randomMeals = MockData.randomMeals
        favoritesMealStore = InMemoryFavoritesMealStore()
    }

    @MainActor
    func makeMealOfTheDayViewModel() -> MealOfTheDayViewModel {
        MealOfTheDayViewModel(getRandomMealUseCase: UITestGetRandomMealUseCase(meals: randomMeals))
    }

    @MainActor
    func makeMealsViewModel() -> MealsViewModel {
        MealsViewModel(
            searchMealsUseCase: UITestSearchMealsUseCase(meals: randomMeals),
            getMealListItemsUseCase: UITestGetMealListItemsUseCase(),
            filterMealsUseCase: UITestFilterMealsUseCase(meals: randomMeals),
            lookupMealByIDUseCase: UITestLookupMealByIDUseCase(meals: randomMeals)
        )
    }

    @MainActor
    func makeFavouritesViewModel() -> FavouritesViewModel {
        FavouritesViewModel(favoritesMealStore: favoritesMealStore)
    }

    func makeFavoritesMealStore() -> FavoritesMealStore {
        favoritesMealStore
    }
}

private struct UITestGetRandomMealUseCase: GetRandomMealUseCase {
    let meals: [Meal]

    func execute() async throws -> Meal? {
        meals.first
    }
}

private struct UITestSearchMealsUseCase: SearchMealsUseCase {
    let meals: [Meal]

    func execute(query: String) async throws -> [Meal] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedQuery.isEmpty else { return [] }
        return meals.filter { $0.strMeal.lowercased().contains(normalizedQuery) }
    }
}

private struct UITestGetMealListItemsUseCase: GetMealListItemsUseCase {
    func execute(type: MealListType) async throws -> MealListItems {
        switch type {
        case .category:
            return .categories(["Seafood", "Vegetarian"])
        case .area:
            return .areas(["Italian", "British"])
        case .ingredient:
            return .ingredients([
                Ingredient(idIngredient: "1", strIngredient: "olive oil", strDescription: nil, strType: nil, strThumb: ""),
                Ingredient(idIngredient: "2", strIngredient: "tomato", strDescription: nil, strType: nil, strThumb: "")
            ])
        }
    }
}

private struct UITestFilterMealsUseCase: FilterMealsUseCase {
    let meals: [Meal]

    func execute(filter: MealFilter) async throws -> [FilteredMeal] {
        let filtered: [Meal]
        switch filter {
        case .category(let value):
            filtered = meals.filter { $0.strCategory.caseInsensitiveCompare(value) == .orderedSame }
        case .area(let value):
            filtered = meals.filter { $0.strArea.caseInsensitiveCompare(value) == .orderedSame }
        case .ingredient(let value):
            filtered = meals.filter { meal in
                meal.ingredients.contains { $0.ingredient.caseInsensitiveCompare(value) == .orderedSame }
            }
        }

        return filtered.map { meal in
            FilteredMeal(idMeal: meal.idMeal, strMeal: meal.strMeal, strMealThumb: meal.strMealThumb)
        }
    }
}

private struct UITestLookupMealByIDUseCase: LookupMealByIDUseCase {
    let meals: [Meal]

    func execute(id: String) async throws -> Meal? {
        meals.first { $0.idMeal == id }
    }
}

private actor InMemoryFavoritesMealStore: FavoritesMealStore {
    private var favorites: [Meal] = []

    func fetchFavorites() async throws -> [Meal] {
        favorites
    }

    func addToFavorites(_ meal: Meal) async throws {
        if favorites.contains(where: { $0.idMeal == meal.idMeal }) {
            return
        }
        favorites.insert(meal, at: 0)
    }

    func removeFromFavorites(idMeal: String) async throws {
        favorites.removeAll { $0.idMeal == idMeal }
    }

    func reorderFavorites(from source: IndexSet, to destination: Int) async throws -> [Meal] {
        var reordered = favorites
        let movingItems = source.sorted(by: >).map { reordered.remove(at: $0) }
        var insertionIndex = destination
        for index in source where index < destination {
            insertionIndex -= 1
        }
        reordered.insert(contentsOf: movingItems.reversed(), at: insertionIndex)
        favorites = reordered
        return favorites
    }

    func isFavorite(idMeal: String) async throws -> Bool {
        favorites.contains { $0.idMeal == idMeal }
    }
}
