import Foundation

actor PreviewFavoritesMealStore: FavoritesMealStore {
    private var favorites: [Meal]
    private var continuations: [UUID: AsyncStream<[Meal]>.Continuation] = [:]

    init(initialMeals: [Meal] = []) {
        self.favorites = initialMeals
    }

    func fetchFavorites() async throws -> [Meal] {
        favorites
    }

    func observeFavorites() async -> AsyncStream<[Meal]> {
        let id = UUID()
        return AsyncStream { continuation in
            Task { self.registerContinuation(continuation, id: id) }
        }
    }

    func addToFavorites(_ meal: Meal) async throws {
        guard favorites.contains(where: { $0.idMeal == meal.idMeal }) == false else { return }
        favorites.insert(meal, at: 0)
        broadcast()
    }

    func removeFromFavorites(idMeal: String) async throws {
        favorites.removeAll { $0.idMeal == idMeal }
        broadcast()
    }

    func reorderFavorites(fromIndices source: [Int], toIndex destination: Int) async throws -> [Meal] {
        var reordered = favorites
        let sortedSource = source.sorted()
        let movingItems = sortedSource.sorted(by: >).map { reordered.remove(at: $0) }
        var insertionIndex = destination
        for index in sortedSource where index < destination {
            insertionIndex -= 1
        }
        reordered.insert(contentsOf: movingItems.reversed(), at: insertionIndex)
        favorites = reordered
        broadcast()
        return favorites
    }

    func isFavorite(idMeal: String) async throws -> Bool {
        favorites.contains { $0.idMeal == idMeal }
    }

    private func registerContinuation(_ continuation: AsyncStream<[Meal]>.Continuation, id: UUID) {
        continuations[id] = continuation
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeContinuation(id: id) }
        }
        continuation.yield(favorites)
    }

    private func removeContinuation(id: UUID) {
        continuations[id] = nil
    }

    private func broadcast() {
        for continuation in continuations.values {
            continuation.yield(favorites)
        }
    }
}
