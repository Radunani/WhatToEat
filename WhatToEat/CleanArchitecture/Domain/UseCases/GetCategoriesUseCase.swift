import Foundation

@MainActor
protocol GetCategoriesUseCase {
    func execute() async throws -> [MealCategory]
}
