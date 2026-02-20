import SwiftUI

struct FavouritesView: View {
    @StateObject private var viewModel: FavouritesViewModel
    @State private var selectedMeal: Meal?
    @Namespace private var transitionNamespace
    private let favoritesMealStore: FavoritesMealStore

    init(viewModel: FavouritesViewModel, favoritesMealStore: FavoritesMealStore = CoreDataFavoritesManager()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.favoritesMealStore = favoritesMealStore
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.meals) { meal in
                    MealListCell(
                        meal: meal,
                        thumbnailSize: .medium,
                        favoritesMealStore: favoritesMealStore
                    )
                        .matchedTransitionSource(id: meal.id, in: transitionNamespace)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedMeal = meal
                        }
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
            .navigationTitle("Favourites")
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
            .navigationDestination(item: $selectedMeal) { meal in
                MealDetailsView(meal: meal, favoritesMealStore: favoritesMealStore)
                    .toolbar(.hidden, for: .tabBar)
                    .navigationTransition(.zoom(sourceID: meal.id, in: transitionNamespace))
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.meals.isEmpty {
                    ContentUnavailableView(
                        "No Favourites",
                        systemImage: "heart",
                        description: Text("Add meals to favourites and they will appear here.")
                    )
                }
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { _ in }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    let store = CoreDataFavoritesManager()
    FavouritesView(
        viewModel: FavouritesViewModel(favoritesMealStore: store),
        favoritesMealStore: store
    )
}
