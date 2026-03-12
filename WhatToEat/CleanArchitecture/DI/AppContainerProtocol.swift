import Foundation

protocol AppContainerProtocol {
    @MainActor
    func makeMealOfTheDayViewModel() -> MealOfTheDayViewModel
    @MainActor
    func makeMealsViewModel() -> MealsViewModel
    @MainActor
    func makeFavoritesViewModel() -> FavoritesViewModel
    @MainActor
    func makeFavoritesMealStore() -> FavoritesMealStore
}
