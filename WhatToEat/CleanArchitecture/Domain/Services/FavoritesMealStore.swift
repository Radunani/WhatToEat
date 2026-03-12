import Foundation

protocol FavoritesMealStore: Sendable {
    func fetchFavorites() async throws -> [Meal]
    func observeFavorites() async -> AsyncStream<[Meal]>
    func addToFavorites(_ meal: Meal) async throws
    func removeFromFavorites(idMeal: String) async throws
    func reorderFavorites(fromIndices source: [Int], toIndex destination: Int) async throws -> [Meal]
    func isFavorite(idMeal: String) async throws -> Bool
}
