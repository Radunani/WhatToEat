import Foundation

protocol SearchMealsUseCase {
    func execute(query: String) async throws -> [Meal]
}

struct SearchMealsUseCaseImpl: SearchMealsUseCase {
    private let repository: MealRepository

    init(repository: MealRepository) {
        self.repository = repository
    }

    func execute(query: String) async throws -> [Meal] {
        try await repository.searchMeals(byName: query)
    }
}

