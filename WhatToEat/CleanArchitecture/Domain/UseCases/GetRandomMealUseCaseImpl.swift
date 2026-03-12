import Foundation

struct GetRandomMealUseCaseImpl: GetRandomMealUseCase {
    private let repository: MealRepository

    init(repository: MealRepository) {
        self.repository = repository
    }

    func execute() async throws -> Meal? {
        try await repository.randomMeal()
    }
}
