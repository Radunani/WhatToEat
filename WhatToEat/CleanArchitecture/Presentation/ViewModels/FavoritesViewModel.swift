import Foundation
import Observation

@MainActor
@Observable
final class FavoritesViewModel {
    private(set) var meals: [Meal] = []
    private(set) var isLoading = false
    private(set) var alertItem: AlertItem?

    @ObservationIgnored
    private let favoritesMealStore: FavoritesMealStore
    @ObservationIgnored
    private var observationTask: Task<Void, Never>?

    init(favoritesMealStore: FavoritesMealStore) {
        self.favoritesMealStore = favoritesMealStore
    }

    func loadFavorites() async {
        guard observationTask == nil else { return }
        isLoading = true
        alertItem = nil
        observationTask = Task { [weak self] in
            guard let self else { return }
            let stream = await self.favoritesMealStore.observeFavorites()
            for await favorites in stream {
                if Task.isCancelled { return }
                self.meals = favorites
                self.isLoading = false
            }
        }
    }

    func removeMeals(at offsets: IndexSet) async {
        let ids = offsets.map { self.meals[$0].idMeal }

        do {
            for id in ids {
                try await favoritesMealStore.removeFromFavorites(idMeal: id)
            }
        } catch {
            alertItem = AlertContext.appError("alert.favorite_remove_failed.message".localized)
        }
    }

    func reorderMeals(from source: IndexSet, to destination: Int) async {
        do {
            _ = try await favoritesMealStore.reorderFavorites(
                fromIndices: source.sorted(),
                toIndex: destination
            )
        } catch {
            alertItem = AlertContext.appError("alert.favorites_reorder_failed.message".localized)
        }
    }

    deinit {
        observationTask?.cancel()
    }
}
