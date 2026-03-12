import Foundation

protocol MealRemoteDataSource: Sendable {
    func randomMeal() async throws -> Meal?
    func lookupMeal(byID id: String) async throws -> Meal?
    func searchMeals(byName name: String) async throws -> [Meal]
    func listCategories() async throws -> [MealCategory]
    func listItems(for type: MealListType) async throws -> MealListItems
    func filterMeals(by filter: MealFilter) async throws -> [FilteredMeal]
}
