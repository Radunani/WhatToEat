import Foundation

protocol MealRemoteDataSource {
    func randomMeal() async throws -> Meal?
    func lookupMeal(byID id: String) async throws -> Meal?
    func searchMeals(byName name: String) async throws -> [Meal]
    func listCategories() async throws -> [MealCategory]
    func listItems(for type: MealListType) async throws -> MealListItems
    func filterMeals(by filter: MealFilter) async throws -> [FilteredMeal]
}

struct MealRemoteDataSourceImpl: MealRemoteDataSource {
    private let service: MealDBServiceProtocol

    init(service: MealDBServiceProtocol) {
        self.service = service
    }

    func randomMeal() async throws -> Meal? {
        try await service.randomMeal()
    }

    func lookupMeal(byID id: String) async throws -> Meal? {
        try await service.lookupMeal(byID: id)
    }

    func searchMeals(byName name: String) async throws -> [Meal] {
        try await service.searchMeals(byName: name)
    }

    func listCategories() async throws -> [MealCategory] {
        try await service.listMealCategories()
    }

    func listItems(for type: MealListType) async throws -> MealListItems {
        try await service.listItems(for: type)
    }

    func filterMeals(by filter: MealFilter) async throws -> [FilteredMeal] {
        try await service.filterMeals(by: filter)
    }
}
