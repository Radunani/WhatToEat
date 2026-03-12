import Foundation
import Observation

@MainActor
@Observable
final class MealDetailsViewModel {
    private(set) var isFavorite = false
    private(set) var isUpdatingFavorite = false
    private(set) var alertItem: AlertItem?

    @ObservationIgnored
    private let meal: Meal
    @ObservationIgnored
    private let favoritesMealStore: FavoritesMealStore
    @ObservationIgnored
    private var favoriteStateRequestID = UUID()

    init(meal: Meal, favoritesMealStore: FavoritesMealStore) {
        self.meal = meal
        self.favoritesMealStore = favoritesMealStore
    }

    func loadFavoriteState() async {
        let requestID = UUID()
        favoriteStateRequestID = requestID

        do {
            let currentValue = try await favoritesMealStore.isFavorite(idMeal: meal.idMeal)
            guard requestID == favoriteStateRequestID else { return }
            isFavorite = currentValue
        } catch {
            guard requestID == favoriteStateRequestID else { return }
            alertItem = AlertContext.appError("alert.favorite_state_load_failed.message".localized)
        }
    }

    func toggleFavorite() async {
        guard !isUpdatingFavorite else { return }
        favoriteStateRequestID = UUID()
        isUpdatingFavorite = true
        defer { isUpdatingFavorite = false }

        do {
            if isFavorite {
                try await favoritesMealStore.removeFromFavorites(idMeal: meal.idMeal)
                isFavorite = false
            } else {
                try await favoritesMealStore.addToFavorites(meal)
                isFavorite = true
            }
        } catch {
            alertItem = AlertContext.appError("alert.favorites_update_failed.message".localized)
        }
    }

    func clearAlert() {
        alertItem = nil
    }
}
