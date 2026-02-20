import Foundation

protocol FilterMealsUseCase {
    func execute(filter: MealFilter) async throws -> [FilteredMeal]
}

struct FilterMealsUseCaseImpl: FilterMealsUseCase {
    private let repository: MealRepository

    init(repository: MealRepository) {
        self.repository = repository
    }

    func execute(filter: MealFilter) async throws -> [FilteredMeal] {
        try await repository.filterMeals(by: filter)
    }
}
