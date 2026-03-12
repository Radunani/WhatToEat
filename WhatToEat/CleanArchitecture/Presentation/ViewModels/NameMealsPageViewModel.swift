import Foundation
import Observation

@MainActor
@Observable
final class NameMealsPageViewModel {
    var query: String
    private(set) var meals: [Meal]
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    @ObservationIgnored
    private let executeSearch: (String) async throws -> [Meal]
    @ObservationIgnored
    private var requestID = UUID()

    init(
        searchMealsUseCase: SearchMealsUseCase,
        initialQuery: String = "Arrabiata",
        initialMeals: [Meal] = []
    ) {
        self.executeSearch = { query in
            try await searchMealsUseCase.execute(query: query)
        }
        self.query = initialQuery
        self.meals = initialMeals
    }

    init(
        executeSearch: @escaping (String) async throws -> [Meal],
        initialQuery: String = "Arrabiata",
        initialMeals: [Meal] = []
    ) {
        self.executeSearch = executeSearch
        self.query = initialQuery
        self.meals = initialMeals
    }

    func loadIfNeeded() async {
        guard meals.isEmpty else { return }
        await search()
    }

    func refresh() async {
        await search()
    }

    func search() async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            meals = []
            errorMessage = nil
            return
        }

        let currentRequestID = UUID()
        requestID = currentRequestID
        errorMessage = nil
        isLoading = true
        defer {
            if requestID == currentRequestID {
                isLoading = false
            }
        }

        do {
            let result = try await executeSearch(trimmedQuery)
            guard requestID == currentRequestID else { return }
            meals = result
        } catch is CancellationError {
            return
        } catch {
            guard requestID == currentRequestID else { return }
            meals = []
            errorMessage = "alert.meals_load_failed.message".localized
        }
    }
}
