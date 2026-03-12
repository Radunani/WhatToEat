import SwiftUI

struct MealsView: View {
    @State private var viewModel: MealsViewModel
    @Namespace private var transitionNamespace
    private let favoritesMealStore: FavoritesMealStore

    init(viewModel: MealsViewModel, favoritesMealStore: FavoritesMealStore) {
        _viewModel = State(initialValue: viewModel)
        self.favoritesMealStore = favoritesMealStore
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("meals.search_by".localized, selection: modeBinding) {
                    ForEach(MealsFilterMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                TabView(selection: modeBinding) {
                    NameMealsPage(
                        viewModel: viewModel.namePageViewModel(),
                        favoritesMealStore: favoritesMealStore,
                        onSelectMeal: { meal in
                            viewModel.send(.selectMeal(meal))
                        },
                        transitionNamespace: transitionNamespace
                    )
                    .tag(MealsFilterMode.name)

                    ForEach(nonNameModes) { mode in
                        FilterSuggestionsPage(
                            viewModel: viewModel.suggestionsPageViewModel(for: mode),
                            onSelect: { value in
                                viewModel.send(.selectSuggestion(value))
                            }
                        )
                        .tag(mode)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("meals.navigation_title".localized)
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: navigationSearchTextBinding,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: viewModel.state.selectedMode.searchPrompt
            )
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(viewModel.state.selectedMode == .name ? .words : .never)
            .submitLabel(viewModel.state.selectedMode == .name ? .search : .done)
            .onSubmit(of: .search) {
                viewModel.submitSearchForSelectedMode()
            }
            .task {
                viewModel.send(.onAppear)
            }
            .navigationDestination(item: routeBinding) { route in
                FilteredMealsResultsView(
                    viewModel: viewModel.makeFilteredMealsResultsViewModel(route: route),
                    favoritesMealStore: favoritesMealStore
                )
                .toolbar(.hidden, for: .tabBar)
            }
            .navigationDestination(item: selectedMealBinding) { meal in
                MealDetailsView(
                    meal: meal,
                    favoritesMealStore: favoritesMealStore,
                    onClose: { viewModel.send(.setSelectedMeal(nil)) }
                )
                .navigationTransition(.zoom(sourceID: meal.id, in: transitionNamespace))
            }
        }
    }

    private var modeBinding: Binding<MealsFilterMode> {
        Binding(
            get: { viewModel.state.selectedMode },
            set: { mode in
                viewModel.send(.changeMode(mode))
            }
        )
    }

    private var routeBinding: Binding<FilterResultsRoute?> {
        Binding(
            get: { viewModel.state.selectedFilterRoute },
            set: { viewModel.send(.setSelectedFilterRoute($0)) }
        )
    }

    private var selectedMealBinding: Binding<Meal?> {
        Binding(
            get: { viewModel.state.selectedMeal },
            set: { viewModel.send(.setSelectedMeal($0)) }
        )
    }

    private var nonNameModes: [MealsFilterMode] {
        MealsFilterMode.allCases.filter { $0 != .name }
    }

    private var navigationSearchTextBinding: Binding<String> {
        Binding(
            get: { viewModel.searchText(for: viewModel.state.selectedMode) },
            set: { viewModel.setSearchText($0, for: viewModel.state.selectedMode) }
        )
    }
}
