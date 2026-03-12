import SwiftUI

struct MealOfTheDayView: View {
    @State private var viewModel: MealOfTheDayViewModel
    @Namespace private var transitionNamespace
    @State private var selectedMeal: Meal?
    private let thumbnailSize: MealThumbnailSize
    private let favoritesMealStore: FavoritesMealStore

    init(
        viewModel: MealOfTheDayViewModel,
        thumbnailSize: MealThumbnailSize = .medium,
        favoritesMealStore: FavoritesMealStore
    ) {
        _viewModel = State(initialValue: viewModel)
        self.thumbnailSize = thumbnailSize
        self.favoritesMealStore = favoritesMealStore
    }
    
    private var alertBinding: Binding<AlertItem?> {
        Binding(
            get: { viewModel.alertItem },
            set: { _ in }
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(viewModel.mealEntries) { entry in
                        mealRow(entry)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .animation(.easeInOut(duration: 0.3), value: viewModel.mealEntries.count)
                .navigationTitle("meal_of_day.navigation_title".localized)
                .refreshable {
                    viewModel.restartLiveFeed()
                }
                .task {
                    viewModel.startInitialFeedIfNeeded()
                }
                .overlay {
                    if viewModel.isLoading {
                        LoadingView()
                    }
                }
                .appAlert(item: alertBinding)
            }
            .navigationDestination(item: $selectedMeal) { meal in
                MealDetailsView(meal: meal, favoritesMealStore: favoritesMealStore)
                    .navigationTransition(.zoom(sourceID: meal.id, in: transitionNamespace))
            }
        }
    }
    
    private func mealRow(_ entry: MealFeedEntry) -> some View {
        Button {
            selectedMeal = entry.meal
        } label: {
            MealListCell(
                meal: entry.meal,
                thumbnailSize: thumbnailSize,
                favoritesMealStore: favoritesMealStore
            )
            .matchedTransitionSource(id: entry.meal.id, in: transitionNamespace)
        }
        .buttonStyle(.plain)
    }
}
