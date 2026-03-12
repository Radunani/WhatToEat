import Foundation
import Observation

@MainActor
@Observable
final class FilteredMealsResultsViewModel {
    let route: FilterResultsRoute

    private(set) var meals: [FilteredMeal] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var selectedMeal: Meal?

    @ObservationIgnored
    private let loadMealsImpl: (FilterResultsRoute) async throws -> [FilteredMeal]
    @ObservationIgnored
    private let resolveMealImpl: (FilteredMeal) async -> Meal?
    @ObservationIgnored
    private var loadRequestID = UUID()
    @ObservationIgnored
    private var resolveTask: Task<Void, Never>?
    @ObservationIgnored
    private var hasLoaded = false

    init(
        route: FilterResultsRoute,
        filterMealsUseCase: FilterMealsUseCase,
        lookupMealByIDUseCase: LookupMealByIDUseCase
    ) {
        self.route = route
        self.loadMealsImpl = { route in
            guard let filter = route.mode.makeFilter(with: route.value) else { return [] }
            return try await filterMealsUseCase.execute(filter: filter)
        }
        self.resolveMealImpl = { filteredMeal in
            try? await lookupMealByIDUseCase.execute(id: filteredMeal.idMeal)
        }
    }

    init(
        route: FilterResultsRoute,
        loadMeals: @escaping (FilterResultsRoute) async throws -> [FilteredMeal],
        resolveMeal: @escaping (FilteredMeal) async -> Meal?
    ) {
        self.route = route
        self.loadMealsImpl = loadMeals
        self.resolveMealImpl = resolveMeal
    }

    func fetchFilteredMeals(for route: FilterResultsRoute) async throws -> [FilteredMeal] {
        try await loadMealsImpl(route)
    }

    func loadResultsIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await loadResults()
    }

    func loadResults() async {
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
            let result = try await fetchFilteredMeals(for: route)
            guard requestID == loadRequestID else { return }
            meals = result
        } catch is CancellationError {
            return
        } catch {
            guard requestID == loadRequestID else { return }
            errorMessage = "content.error.load_meals_failed".localized
        }
    }

    func select(_ filteredMeal: FilteredMeal) {
        resolveTask?.cancel()
        resolveTask = Task { [weak self] in
            guard let self else { return }
            let meal = await resolveMealImpl(filteredMeal)
            guard !Task.isCancelled else { return }
            selectedMeal = meal
        }
    }

    func clearSelectedMeal() {
        selectedMeal = nil
    }
}
