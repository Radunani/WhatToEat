import Foundation

protocol MealDBServiceProtocol: Sendable {
    func searchMeals(byName name: String) async throws -> [MealDTO]
    func listMeals(byFirstLetter letter: Character) async throws -> [MealDTO]
    func lookupMeal(byID id: String) async throws -> MealDTO?
    func randomMeal() async throws -> MealDTO?
    func listMealCategories() async throws -> [MealCategoryDTO]
    func listItems(for type: MealListType) async throws -> MealListItems
    func filterMeals(by filter: MealFilter) async throws -> [FilteredMealDTO]
    func mealThumbnailURL(from value: String, size: MealThumbnailSize) -> URL?
    func ingredientImageURL(for ingredient: String, size: IngredientImageSize) -> URL?
}
