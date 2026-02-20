import Foundation

protocol FavoritesMealStore {
    func fetchFavorites() async throws -> [Meal]
    func addToFavorites(_ meal: Meal) async throws
    func removeFromFavorites(idMeal: String) async throws
    func reorderFavorites(from source: IndexSet, to destination: Int) async throws -> [Meal]
    func isFavorite(idMeal: String) async throws -> Bool
}
