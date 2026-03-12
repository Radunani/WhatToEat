import SwiftUI

struct FilteredMealsResultsView: View {
    @State private var viewModel: FilteredMealsResultsViewModel
    let favoritesMealStore: FavoritesMealStore
    @Namespace private var transitionNamespace

    init(
        viewModel: FilteredMealsResultsViewModel,
        favoritesMealStore: FavoritesMealStore
    ) {
        _viewModel = State(initialValue: viewModel)
        self.favoritesMealStore = favoritesMealStore
    }

    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                Section {
                    NoResultsView(item: NoResultsContext.error(errorMessage))
                }
            } else if viewModel.meals.isEmpty && !viewModel.isLoading {
                Section {
                    NoResultsView(item: NoResultsContext.filteredMeals(for: viewModel.route.value))
                }
            } else {
                ForEach(viewModel.meals) { meal in
                    Button {
                        viewModel.select(meal)
                    } label: {
                        MealListCell(
                            meal: meal.asPreviewMeal,
                            thumbnailSize: .medium,
                            favoritesMealStore: favoritesMealStore,
                            showsFavoriteButton: false
                        )
                        .matchedTransitionSource(id: meal.id, in: transitionNamespace)
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .navigationTitle(viewModel.route.title)
        .task {
            await viewModel.loadResultsIfNeeded()
        }
        .navigationDestination(item: mealBinding) { meal in
            MealDetailsView(
                meal: meal,
                favoritesMealStore: favoritesMealStore,
                onClose: { viewModel.clearSelectedMeal() }
            )
            .toolbar(.hidden, for: .tabBar)
            .navigationTransition(.zoom(sourceID: meal.id, in: transitionNamespace))
        }
    }

    private var mealBinding: Binding<Meal?> {
        Binding(
            get: { viewModel.selectedMeal },
            set: { viewModel.selectedMeal = $0 }
        )
    }
}
