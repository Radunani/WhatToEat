import Foundation

protocol GetRandomMealUseCase {
    func execute() async throws -> Meal?
}

struct GetRandomMealUseCaseImpl: GetRandomMealUseCase {
    private let repository: MealRepository

    init(repository: MealRepository) {
        self.repository = repository
    }

    func execute() async throws -> Meal? {
        try await repository.randomMeal()
    }
}

