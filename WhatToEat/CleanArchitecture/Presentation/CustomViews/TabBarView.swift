import SwiftUI

struct TabBarView: View {
    private let container: AppContainerProtocol
    
    init(container: AppContainerProtocol) {
        self.container = container
    }
    
    var body: some View {
        TabView {
            Tab("Meal of the day", systemImage: "sun.max") {
                MealOfTheDayView(
                    viewModel: container.makeMealOfTheDayViewModel(),
                    favoritesMealStore: container.makeFavoritesMealStore()
                )
            }
            
            Tab("Meals", systemImage: "fork.knife") {
                MealsView(
                    viewModel: container.makeMealsViewModel(),
                    favoritesMealStore: container.makeFavoritesMealStore()
                )
            }
            
            Tab("Favourites", systemImage: "heart") {
                FavouritesView(
                    viewModel: container.makeFavouritesViewModel(),
                    favoritesMealStore: container.makeFavoritesMealStore()
                )
            }
        }
    }
}

#Preview {
    TabBarView(container: AppContainer())
}
