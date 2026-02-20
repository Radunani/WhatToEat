import Foundation

struct MealRepositoryImpl: MealRepository {
    private let remoteDataSource: MealRemoteDataSource

    init(remoteDataSource: MealRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func randomMeal() async throws -> Meal? {
        try await remoteDataSource.randomMeal()
    }

    func lookupMeal(byID id: String) async throws -> Meal? {
        try await remoteDataSource.lookupMeal(byID: id)
    }

    func searchMeals(byName name: String) async throws -> [Meal] {
        try await remoteDataSource.searchMeals(byName: name)
    }

    func listCategories() async throws -> [MealCategory] {
        try await remoteDataSource.listCategories()
    }

    func listItems(for type: MealListType) async throws -> MealListItems {
        try await remoteDataSource.listItems(for: type)
    }

    func filterMeals(by filter: MealFilter) async throws -> [FilteredMeal] {
        try await remoteDataSource.filterMeals(by: filter)
    }
}
