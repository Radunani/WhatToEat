import Foundation

@MainActor
protocol GetRandomMealUseCase {
    func execute() async throws -> Meal?
}
