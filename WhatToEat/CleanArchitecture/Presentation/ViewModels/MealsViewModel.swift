import Foundation

@MainActor
final class MealsViewModel: ObservableObject {
    @Published private(set) var meals: [Meal] = []
    @Published private(set) var categories: [MealCategory] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let searchMealsUseCase: SearchMealsUseCase
    private let getCategoriesUseCase: GetCategoriesUseCase

    init(
        searchMealsUseCase: SearchMealsUseCase,
        getCategoriesUseCase: GetCategoriesUseCase
    ) {
        self.searchMealsUseCase = searchMealsUseCase
        self.getCategoriesUseCase = getCategoriesUseCase
    }

    func loadInitialData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let fetchedMeals = searchMealsUseCase.execute(query: "Arrabiata")
            async let fetchedCategories = getCategoriesUseCase.execute()
            meals = try await fetchedMeals
            categories = try await fetchedCategories
        } catch {
            errorMessage = "Could not load meals."
        }

        isLoading = false
    }

    func search(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isLoading = true
        errorMessage = nil

        do {
            meals = try await searchMealsUseCase.execute(query: query)
        } catch {
            errorMessage = "Could not search meals."
        }

        isLoading = false
    }
}

