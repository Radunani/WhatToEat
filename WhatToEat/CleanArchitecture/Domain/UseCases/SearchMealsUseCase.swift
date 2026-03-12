import Foundation

@MainActor
protocol SearchMealsUseCase {
    func execute(query: String) async throws -> [Meal]
}
