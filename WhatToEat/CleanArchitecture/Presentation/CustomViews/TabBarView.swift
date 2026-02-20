import SwiftUI

struct TabBarView: View {
    private let container: AppContainerProtocol
    
    init(container: AppContainerProtocol) {
        self.container = container
    }
    
    var body: some View {
        TabView {
            Tab("Meal of the day", systemImage: "sun.max") {
                MealOfTheDayView(viewModel: container.makeMealOfTheDayViewModel())
            }
            
            Tab("Meals", systemImage: "fork.knife") {
                MealsView(viewModel: container.makeMealsViewModel())
            }
            
            Tab("Favourites", systemImage: "heart") {
            }
        }
    }
}

#Preview {
    TabBarView(container: AppContainer())
}
