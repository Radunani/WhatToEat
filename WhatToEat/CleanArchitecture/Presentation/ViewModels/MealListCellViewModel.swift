import Foundation
import Observation

@MainActor
@Observable
final class MealListCellViewModel {
    private(set) var isFavorite = false
    private(set) var isUpdatingFavorite = false

    let meal: Meal
    @ObservationIgnored
    private let favoritesMealStore: FavoritesMealStore
    @ObservationIgnored
    private var observationTask: Task<Void, Never>?

    init(meal: Meal, favoritesMealStore: FavoritesMealStore) {
        self.meal = meal
        self.favoritesMealStore = favoritesMealStore
    }

    func startObservingFavorites() {
        guard observationTask == nil else { return }
        observationTask = Task { [weak self] in
            guard let self else { return }
            let stream = await self.favoritesMealStore.observeFavorites()
            for await favorites in stream {
                if Task.isCancelled { return }
                self.isFavorite = favorites.contains { $0.idMeal == self.meal.idMeal }
            }
        }
    }

    func stopObservingFavorites() {
        observationTask?.cancel()
        observationTask = nil
    }

    func toggleFavorite() async {
        guard !isUpdatingFavorite else { return }
        isUpdatingFavorite = true
        defer { isUpdatingFavorite = false }

        let willBeFavorite = !isFavorite
        isFavorite = willBeFavorite

        do {
            if willBeFavorite {
                try await favoritesMealStore.addToFavorites(self.meal)
            } else {
                try await favoritesMealStore.removeFromFavorites(idMeal: self.meal.idMeal)
            }
        } catch {
            isFavorite.toggle()
        }
    }

    deinit {
        observationTask?.cancel()
    }
}
