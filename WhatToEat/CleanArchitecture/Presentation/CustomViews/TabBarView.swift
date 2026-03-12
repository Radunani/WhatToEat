import SwiftUI

@MainActor
struct TabBarView: View {
    private let mealOfTheDayViewModel: MealOfTheDayViewModel
    private let mealsViewModel: MealsViewModel
    private let favoritesViewModel: FavoritesViewModel
    private let favoritesMealStore: FavoritesMealStore
    
    init(container: AppContainerProtocol) {
        self.mealOfTheDayViewModel = container.makeMealOfTheDayViewModel()
        self.mealsViewModel = container.makeMealsViewModel()
        self.favoritesViewModel = container.makeFavoritesViewModel()
        self.favoritesMealStore = container.makeFavoritesMealStore()
    }
    
    var body: some View {
        TabView {
            Tab("tab.meal_of_day".localized, systemImage: "sun.max") {
                MealOfTheDayView(
                    viewModel: mealOfTheDayViewModel,
                    favoritesMealStore: favoritesMealStore
                )
            }
            
            Tab("tab.meals".localized, systemImage: "fork.knife") {
                MealsView(
                    viewModel: mealsViewModel,
                    favoritesMealStore: favoritesMealStore
                )
            }
            
            Tab("tab.favorites".localized, systemImage: "heart") {
                FavoritesView(
                    viewModel: favoritesViewModel,
                    favoritesMealStore: favoritesMealStore
                )
            }
        }
    }
}
