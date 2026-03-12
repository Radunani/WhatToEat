import Foundation

@MainActor
protocol LookupMealByIDUseCase {
    func execute(id: String) async throws -> Meal?
}
