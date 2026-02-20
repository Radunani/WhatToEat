import Foundation

@MainActor
final class FavouritesViewModel: ObservableObject {
    @Published private(set) var meals: [Meal] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let favoritesMealStore: FavoritesMealStore
    private var loadRequestID = UUID()

    init(favoritesMealStore: FavoritesMealStore) {
        self.favoritesMealStore = favoritesMealStore
    }

    func loadFavorites() async {
        let requestID = UUID()
        loadRequestID = requestID
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await favoritesMealStore.fetchFavorites()
            guard requestID == loadRequestID else { return }
            meals = result
        } catch {
            guard requestID == loadRequestID else { return }
            errorMessage = "Could not load favourites."
        }
    }

    func removeMeals(at offsets: IndexSet) async {
        loadRequestID = UUID()
        let ids = offsets.map { meals[$0].idMeal }

        do {
            for id in ids {
                try await favoritesMealStore.removeFromFavorites(idMeal: id)
            }
            meals.remove(atOffsets: offsets)
        } catch {
            errorMessage = "Could not remove favourite meal."
        }
    }

    func reorderMeals(from source: IndexSet, to destination: Int) async {
        loadRequestID = UUID()
        do {
            meals = try await favoritesMealStore.reorderFavorites(from: source, to: destination)
        } catch {
            errorMessage = "Could not reorder favourites."
        }
    }
}
