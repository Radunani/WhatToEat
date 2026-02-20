import Foundation

struct FilterResultsRoute: Identifiable, Hashable {
    let mode: MealsFilterMode
    let value: String

    var id: String { "\(mode.rawValue)::\(value)" }
    var title: String { "\(mode.title): \(value)" }
}

enum MealsFilterMode: String, CaseIterable, Identifiable {
    case name
    case category
    case area
    case ingredient

    var id: String { rawValue }

    var title: String {
        switch self {
        case .name:
            return "Name"
        case .category:
            return "Category"
        case .area:
            return "Area"
        case .ingredient:
            return "Ingredient"
        }
    }

    var placeholder: String {
        switch self {
        case .name:
            return "Enter meal name"
        case .category:
            return "Enter category"
        case .area:
            return "Enter area"
        case .ingredient:
            return "Enter ingredient"
        }
    }

    var listType: MealListType? {
        switch self {
        case .name:
            return nil
        case .category:
            return .category
        case .area:
            return .area
        case .ingredient:
            return .ingredient
        }
    }

    func makeFilter(with value: String) -> MealFilter? {
        switch self {
        case .name:
            return nil
        case .category:
            return .category(value)
        case .area:
            return .area(value)
        case .ingredient:
            return .ingredient(value)
        }
    }
}

@MainActor
final class MealsViewModel: ObservableObject {
    @Published var selectedMode: MealsFilterMode = .name
    @Published var nameQuery: String = "Arrabiata"
    @Published private var nonNameQueryByMode: [MealsFilterMode: String] = [:]
    @Published var selectedFilterRoute: FilterResultsRoute?
    @Published var selectedMeal: Meal?
    @Published private(set) var meals: [Meal] = []
    @Published private(set) var filterValuesByMode: [MealsFilterMode: [String]] = [:]
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let searchMealsUseCase: SearchMealsUseCase
    private let getMealListItemsUseCase: GetMealListItemsUseCase
    private let filterMealsUseCase: FilterMealsUseCase
    private let lookupMealByIDUseCase: LookupMealByIDUseCase
    private var nameSearchRequestID = UUID()
    private var detailRequestID = UUID()
    private var filterValuesRequestID = UUID()
    private var modeChangeTask: Task<Void, Never>?
    private var inFlightCount = 0

    init(
        searchMealsUseCase: SearchMealsUseCase,
        getMealListItemsUseCase: GetMealListItemsUseCase,
        filterMealsUseCase: FilterMealsUseCase,
        lookupMealByIDUseCase: LookupMealByIDUseCase
    ) {
        self.searchMealsUseCase = searchMealsUseCase
        self.getMealListItemsUseCase = getMealListItemsUseCase
        self.filterMealsUseCase = filterMealsUseCase
        self.lookupMealByIDUseCase = lookupMealByIDUseCase
    }

    func suggestions(for mode: MealsFilterMode) -> [String] {
        guard mode != .name else { return [] }
        return filterValuesByMode[mode] ?? []
    }

    func filteredSuggestions(for mode: MealsFilterMode) -> [String] {
        let values = suggestions(for: mode)
        guard mode != .name else { return values }

        let query = searchText(for: mode).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return values }
        return values.filter { value in
            value.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
    }

    func searchText(for mode: MealsFilterMode) -> String {
        switch mode {
        case .name:
            return nameQuery
        case .category, .area, .ingredient:
            return nonNameQueryByMode[mode] ?? ""
        }
    }

    func setSearchText(_ value: String, for mode: MealsFilterMode) {
        switch mode {
        case .name:
            nameQuery = value
        case .category, .area, .ingredient:
            nonNameQueryByMode[mode] = value
        }
    }

    func loadInitialData() {
        if selectedMode == .name && meals.isEmpty {
            Task { [weak self] in
                guard let self else { return }
                await self.searchByName()
            }
            return
        }

        changeMode(to: selectedMode)
    }

    func changeMode(to mode: MealsFilterMode) {
        modeChangeTask?.cancel()
        invalidateRequests()
        selectedMode = mode
        errorMessage = nil
        selectedFilterRoute = nil

        guard mode != .name else { return }
        guard filterValuesByMode[mode] == nil else { return }

        modeChangeTask = Task { [weak self] in
            guard let self else { return }
            await self.loadFilterValuesIfNeeded(for: mode)
        }
    }

    func searchByName() async {
        let trimmedQuery = nameQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            meals = []
            return
        }

        let requestID = UUID()
        nameSearchRequestID = requestID
        errorMessage = nil
        beginLoading()
        defer { endLoading() }

        do {
            let result = try await searchMealsUseCase.execute(query: trimmedQuery)
            guard requestID == nameSearchRequestID else { return }
            meals = result
        } catch is CancellationError {
            return
        } catch {
            guard requestID == nameSearchRequestID else { return }
            errorMessage = "Could not load meals."
        }
    }

    func openResultsForSuggestion(_ value: String) {
        guard selectedMode != .name else { return }
        selectedFilterRoute = FilterResultsRoute(mode: selectedMode, value: value)
    }

    func openMealDetails(for meal: Meal) {
        selectedMeal = meal
    }

    func fetchMealDetails(for filteredMeal: FilteredMeal) async -> Meal? {
        let requestID = UUID()
        detailRequestID = requestID
        beginLoading()
        defer { endLoading() }

        do {
            let meal = try await lookupMealByIDUseCase.execute(id: filteredMeal.idMeal)
            guard requestID == detailRequestID else { return nil }
            return meal
        } catch is CancellationError {
            return nil
        } catch {
            guard requestID == detailRequestID else { return nil }
            errorMessage = "Could not load meal details."
            return nil
        }
    }

    func fetchFilteredMeals(for route: FilterResultsRoute) async throws -> [FilteredMeal] {
        guard let filter = route.mode.makeFilter(with: route.value) else { return [] }
        return try await filterMealsUseCase.execute(filter: filter)
    }

    private func loadFilterValuesIfNeeded(for mode: MealsFilterMode) async {
        let requestID = UUID()
        filterValuesRequestID = requestID

        guard let listType = mode.listType else {
            filterValuesByMode[mode] = []
            return
        }

        beginLoading()
        defer { endLoading() }

        do {
            let items = try await getMealListItemsUseCase.execute(type: listType)
            guard requestID == filterValuesRequestID else { return }
            filterValuesByMode[mode] = Self.values(from: items)
        } catch is CancellationError {
            return
        } catch {
            guard requestID == filterValuesRequestID else { return }
            filterValuesByMode[mode] = []
        }
    }

    private static func values(from items: MealListItems) -> [String] {
        switch items {
        case .categories(let values):
            return values.sorted()
        case .areas(let values):
            return values.sorted()
        case .ingredients(let values):
            return values.map(\.strIngredient).sorted()
        }
    }

    private func beginLoading() {
        inFlightCount += 1
        isLoading = inFlightCount > 0
    }

    private func endLoading() {
        inFlightCount = max(0, inFlightCount - 1)
        isLoading = inFlightCount > 0
    }

    private func invalidateRequests() {
        nameSearchRequestID = UUID()
        detailRequestID = UUID()
        filterValuesRequestID = UUID()
    }
}
