import SwiftUI

struct NameMealsPage: View {
    @Bindable var viewModel: NameMealsPageViewModel
    let favoritesMealStore: FavoritesMealStore
    let onSelectMeal: (Meal) -> Void
    let transitionNamespace: Namespace.ID

    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                Section {
                    NoResultsView(item: NoResultsContext.error(errorMessage))
                }
            } else {
                if !viewModel.meals.isEmpty {
                    Section("section.results".localized) {
                        ForEach(viewModel.meals) { meal in
                            Button {
                                onSelectMeal(meal)
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
                    }
                }

                if !viewModel.isLoading && viewModel.meals.isEmpty {
                    Section {
                        NoResultsView(item: NoResultsContext.mealsByName)
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }
}
