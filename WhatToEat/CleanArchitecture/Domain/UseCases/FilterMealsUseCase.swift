import Foundation

@MainActor
protocol FilterMealsUseCase {
    func execute(filter: MealFilter) async throws -> [FilteredMeal]
}
