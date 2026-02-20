import SwiftUI

struct MealsView: View {
    @StateObject private var viewModel: MealsViewModel
    @Namespace private var transitionNamespace
    private let favoritesMealStore: FavoritesMealStore

    init(viewModel: MealsViewModel, favoritesMealStore: FavoritesMealStore = CoreDataFavoritesManager()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.favoritesMealStore = favoritesMealStore
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Search by", selection: modeBinding) {
                    ForEach(MealsFilterMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                TabView(selection: modeBinding) {
                    NameMealsPage(
                        meals: viewModel.meals,
                        isLoading: viewModel.isLoading && viewModel.selectedMode == .name,
                        favoritesMealStore: favoritesMealStore,
                        onSelectMeal: { meal in
                            viewModel.openMealDetails(for: meal)
                        },
                        onRefresh: {
                            await viewModel.searchByName()
                        },
                        transitionNamespace: transitionNamespace
                    )
                    .tag(MealsFilterMode.name)

                    ForEach(nonNameModes) { mode in
                        FilterSuggestionsPage(
                            mode: mode,
                            suggestions: viewModel.filteredSuggestions(for: mode),
                            isLoading: viewModel.isLoading && viewModel.selectedMode == mode,
                            onSelect: { value in
                                viewModel.openResultsForSuggestion(value)
                            }
                        )
                        .tag(mode)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Meals")
            .searchable(
                text: navigationSearchTextBinding,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: searchPrompt
            )
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(viewModel.selectedMode == .name ? .words : .never)
            .submitLabel(viewModel.selectedMode == .name ? .search : .done)
            .onSubmit(of: .search) {
                if viewModel.selectedMode == .name {
                    Task { await viewModel.searchByName() }
                }
            }
            .task {
                viewModel.loadInitialData()
            }
            .navigationDestination(item: routeBinding) { route in
                FilteredMealsResultsView(
                    route: route,
                    favoritesMealStore: favoritesMealStore,
                    loadMeals: { route in
                        try await viewModel.fetchFilteredMeals(for: route)
                    },
                    resolveMeal: { filteredMeal in
                        await viewModel.fetchMealDetails(for: filteredMeal)
                    }
                )
            }
            .navigationDestination(item: selectedMealBinding) { meal in
                MealDetailsView(
                    meal: meal,
                    favoritesMealStore: favoritesMealStore,
                    onClose: { viewModel.selectedMeal = nil }
                )
                    .toolbar(.hidden, for: .tabBar)
                    .navigationTransition(.zoom(sourceID: meal.id, in: transitionNamespace))
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

    private var modeBinding: Binding<MealsFilterMode> {
        Binding(
            get: { viewModel.selectedMode },
            set: { mode in
                viewModel.changeMode(to: mode)
            }
        )
    }

    private var routeBinding: Binding<FilterResultsRoute?> {
        Binding(
            get: { viewModel.selectedFilterRoute },
            set: { viewModel.selectedFilterRoute = $0 }
        )
    }

    private var selectedMealBinding: Binding<Meal?> {
        Binding(
            get: { viewModel.selectedMeal },
            set: { viewModel.selectedMeal = $0 }
        )
    }

    private var nonNameModes: [MealsFilterMode] {
        MealsFilterMode.allCases.filter { $0 != .name }
    }

    private var navigationSearchTextBinding: Binding<String> {
        Binding(
            get: { viewModel.searchText(for: viewModel.selectedMode) },
            set: { viewModel.setSearchText($0, for: viewModel.selectedMode) }
        )
    }

    private var searchPrompt: String {
        switch viewModel.selectedMode {
        case .name:
            return "Search meals by name"
        case .category:
            return "Filter categories"
        case .area:
            return "Filter areas"
        case .ingredient:
            return "Filter ingredients"
        }
    }
}

private struct NameMealsPage: View {
    let meals: [Meal]
    let isLoading: Bool
    let favoritesMealStore: FavoritesMealStore
    let onSelectMeal: (Meal) -> Void
    let onRefresh: () async -> Void
    let transitionNamespace: Namespace.ID

    var body: some View {
        List {
            if !meals.isEmpty {
                Section("Results") {
                    ForEach(meals) { meal in
                        MealListCell(
                            meal: meal,
                            thumbnailSize: .medium,
                            favoritesMealStore: favoritesMealStore
                        )
                            .matchedTransitionSource(id: meal.id, in: transitionNamespace)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onSelectMeal(meal)
                            }
                            .listRowSeparator(.hidden)
                    }
                }
            }

            if !isLoading && meals.isEmpty {
                Section {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "fork.knife",
                        description: Text("Adjust your filter and try searching again.")
                    )
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await onRefresh()
        }
    }
}

private struct FilterSuggestionsPage: View {
    let mode: MealsFilterMode
    let suggestions: [String]
    let isLoading: Bool
    let onSelect: (String) -> Void

    var body: some View {
        List {
            if !suggestions.isEmpty {
                Section("Suggestions") {
                    ForEach(suggestions, id: \.self) { value in
                        Button(value) {
                            onSelect(value)
                        }
                    }
                }
            }

            if !isLoading && suggestions.isEmpty {
                Section {
                    ContentUnavailableView(
                        "No Suggestions",
                        systemImage: "line.3.horizontal.decrease.circle",
                        description: Text("No items are available for \(mode.title.lowercased()) right now.")
                    )
                }
            }
        }
        .listStyle(.plain)
    }
}

private struct FilteredMealsResultsView: View {
    let route: FilterResultsRoute
    let favoritesMealStore: FavoritesMealStore
    let loadMeals: (FilterResultsRoute) async throws -> [FilteredMeal]
    let resolveMeal: (FilteredMeal) async -> Meal?
    @Namespace private var transitionNamespace
    @State private var selectedMeal: Meal?
    @State private var meals: [FilteredMeal] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var loadRequestID = UUID()

    var body: some View {
        List {
            if let errorMessage {
                Section {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                }
            } else if meals.isEmpty && !isLoading {
                Section {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "fork.knife",
                        description: Text("No meals found for \(route.value).")
                    )
                }
            } else {
                ForEach(meals) { meal in
                    MealListCell(
                        meal: previewMeal(from: meal),
                        thumbnailSize: .medium,
                        favoritesMealStore: favoritesMealStore
                    )
                        .matchedTransitionSource(id: meal.id, in: transitionNamespace)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Task {
                                selectedMeal = await resolveMeal(meal)
                            }
                        }
                        .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .navigationTitle(route.title)
        .task(id: route.id) {
            await loadResults()
        }
        .navigationDestination(item: mealBinding) { meal in
            MealDetailsView(
                meal: meal,
                favoritesMealStore: favoritesMealStore,
                onClose: { selectedMeal = nil }
            )
                .toolbar(.hidden, for: .tabBar)
                .navigationTransition(.zoom(sourceID: meal.id, in: transitionNamespace))
        }
    }

    private var mealBinding: Binding<Meal?> {
        Binding(
            get: { selectedMeal },
            set: { selectedMeal = $0 }
        )
    }

    private func previewMeal(from filteredMeal: FilteredMeal) -> Meal {
        Meal(
            idMeal: filteredMeal.idMeal,
            strMeal: filteredMeal.strMeal,
            strMealAlternate: nil,
            strCategory: "",
            strArea: "",
            strInstructions: "",
            strMealThumb: filteredMeal.strMealThumb,
            strTags: nil,
            strYoutube: nil,
            strSource: nil,
            strImageSource: nil,
            strCreativeCommonsConfirmed: nil,
            dateModified: nil,
            ingredients: []
        )
    }

    @MainActor
    private func loadResults() async {
        let requestID = UUID()
        loadRequestID = requestID
        meals = []
        errorMessage = nil
        isLoading = true
        defer {
            if requestID == loadRequestID {
                isLoading = false
            }
        }

        do {
            let result = try await loadMeals(route)
            guard requestID == loadRequestID else { return }
            meals = result
        } catch is CancellationError {
            return
        } catch {
            guard requestID == loadRequestID else { return }
            errorMessage = "Could not load meals."
        }
    }
}

#Preview {
    let container = AppContainer()
    MealsView(
        viewModel: container.makeMealsViewModel(),
        favoritesMealStore: container.makeFavoritesMealStore()
    )
}
