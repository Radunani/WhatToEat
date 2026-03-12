import Foundation
import Observation

@MainActor
@Observable
final class MealsViewModel {
    private(set) var state = MealsState()

    @ObservationIgnored
    private let filterMealsUseCase: FilterMealsUseCase
    @ObservationIgnored
    private let lookupMealByIDUseCase: LookupMealByIDUseCase
    @ObservationIgnored
    private let namePageVM: NameMealsPageViewModel
    @ObservationIgnored
    private let getMealListItemsUseCase: GetMealListItemsUseCase
    @ObservationIgnored
    private var filterPageVMByMode: [MealsFilterMode: FilterSuggestionsPageViewModel] = [:]
    @ObservationIgnored
    private var modeLoadTask: Task<Void, Never>?
    @ObservationIgnored
    private var nameSearchTask: Task<Void, Never>?

    init(
        searchMealsUseCase: SearchMealsUseCase,
        getMealListItemsUseCase: GetMealListItemsUseCase,
        filterMealsUseCase: FilterMealsUseCase,
        lookupMealByIDUseCase: LookupMealByIDUseCase
    ) {
        self.filterMealsUseCase = filterMealsUseCase
        self.lookupMealByIDUseCase = lookupMealByIDUseCase
        self.getMealListItemsUseCase = getMealListItemsUseCase
        self.namePageVM = NameMealsPageViewModel(searchMealsUseCase: searchMealsUseCase)
    }

    func send(_ action: MealsAction) {
        switch action {
        case .onAppear:
            scheduleModeLoad(for: state.selectedMode)

        case .changeMode(let mode):
            state.selectedMode = mode
            state.selectedFilterRoute = nil
            scheduleModeLoad(for: mode)

        case .selectSuggestion(let value):
            guard state.selectedMode != .name else { return }
            state.selectedFilterRoute = FilterResultsRoute(mode: state.selectedMode, value: value)

        case .selectMeal(let meal):
            state.selectedMeal = meal

        case .setSelectedFilterRoute(let route):
            state.selectedFilterRoute = route

        case .setSelectedMeal(let meal):
            state.selectedMeal = meal
        }
    }

    func namePageViewModel() -> NameMealsPageViewModel {
        namePageVM
    }

    func suggestionsPageViewModel(for mode: MealsFilterMode) -> FilterSuggestionsPageViewModel {
        precondition(mode != .name, "Name mode should use NameMealsPageViewModel")
        if let existing = filterPageVMByMode[mode] {
            return existing
        }
        let created = FilterSuggestionsPageViewModel(
            mode: mode,
            getMealListItemsUseCase: getMealListItemsUseCase
        )
        filterPageVMByMode[mode] = created
        return created
    }

    func searchText(for mode: MealsFilterMode) -> String {
        if mode == .name {
            return namePageVM.query
        }
        return suggestionsPageViewModel(for: mode).query
    }

    func setSearchText(_ text: String, for mode: MealsFilterMode) {
        if mode == .name {
            namePageVM.query = text
        } else {
            suggestionsPageViewModel(for: mode).query = text
        }
    }

    func submitSearchForSelectedMode() {
        guard state.selectedMode == .name else { return }
        nameSearchTask?.cancel()
        nameSearchTask = Task { [weak self] in
            guard let self else { return }
            await self.namePageVM.search()
        }
    }

    func makeFilteredMealsResultsViewModel(route: FilterResultsRoute) -> FilteredMealsResultsViewModel {
        FilteredMealsResultsViewModel(
            route: route,
            filterMealsUseCase: filterMealsUseCase,
            lookupMealByIDUseCase: lookupMealByIDUseCase
        )
    }

    private func scheduleModeLoad(for mode: MealsFilterMode) {
        modeLoadTask?.cancel()
        modeLoadTask = Task { [weak self] in
            guard let self else { return }
            if mode == .name {
                await self.namePageVM.loadIfNeeded()
            } else {
                await self.suggestionsPageViewModel(for: mode).loadIfNeeded()
            }
        }
    }

    deinit {
        modeLoadTask?.cancel()
        nameSearchTask?.cancel()
    }
}
