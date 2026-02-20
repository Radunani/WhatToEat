import Foundation

@MainActor
final class MealDetailsViewModel: ObservableObject {
    @Published private(set) var isFavorite = false
    @Published private(set) var isUpdatingFavorite = false
    @Published private(set) var errorMessage: String?

    private let meal: Meal
    private let favoritesMealStore: FavoritesMealStore
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
            errorMessage = "Could not load favourite state."
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
            errorMessage = "Could not update favourites."
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
