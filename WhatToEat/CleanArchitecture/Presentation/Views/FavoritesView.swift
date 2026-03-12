import SwiftUI

struct FavoritesView: View {
    @State private var viewModel: FavoritesViewModel
    @State private var selectedMeal: Meal?
    @Namespace private var transitionNamespace
    private let favoritesMealStore: FavoritesMealStore

    init(viewModel: FavoritesViewModel, favoritesMealStore: FavoritesMealStore) {
        _viewModel = State(initialValue: viewModel)
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
            VStack(spacing: 0) {
                List {
                    ForEach(viewModel.meals) { meal in
                        Button {
                            selectedMeal = meal
                        } label: {
                            MealListCell(
                                meal: meal,
                                thumbnailSize: .medium,
                                favoritesMealStore: favoritesMealStore
                            )
                            .matchedTransitionSource(id: meal.id, in: transitionNamespace)
                        }
                        .buttonStyle(.plain)
                        .listRowSeparator(.hidden)
                    }
                    .onDelete { offsets in
                        Task { await viewModel.removeMeals(at: offsets) }
                    }
                    .onMove { source, destination in
                        Task { await viewModel.reorderMeals(from: source, to: destination) }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("favorites.navigation_title".localized)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                }
                .task {
                    await viewModel.loadFavorites()
                }
                .refreshable {
                    await viewModel.loadFavorites()
                }
                .overlay {
                    if viewModel.isLoading {
                        LoadingView()
                    } else if viewModel.meals.isEmpty {
                        NoResultsView(item: NoResultsContext.favorites)
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
}
