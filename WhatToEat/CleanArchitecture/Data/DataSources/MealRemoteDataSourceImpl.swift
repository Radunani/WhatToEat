import Foundation

struct MealRemoteDataSourceImpl: MealRemoteDataSource {
    private let service: MealDBServiceProtocol

    init(service: MealDBServiceProtocol) {
        self.service = service
    }

    func randomMeal() async throws -> Meal? {
        try await service.randomMeal()?.toDomain()
    }

    func lookupMeal(byID id: String) async throws -> Meal? {
        try await service.lookupMeal(byID: id)?.toDomain()
    }

    func searchMeals(byName name: String) async throws -> [Meal] {
        try await service.searchMeals(byName: name).map { $0.toDomain() }
    }

    func listCategories() async throws -> [MealCategory] {
        try await service.listMealCategories().map { $0.toDomain() }
    }

    func listItems(for type: MealListType) async throws -> MealListItems {
        try await service.listItems(for: type)
    }

    func filterMeals(by filter: MealFilter) async throws -> [FilteredMeal] {
        try await service.filterMeals(by: filter).map { $0.toDomain() }
    }
}
