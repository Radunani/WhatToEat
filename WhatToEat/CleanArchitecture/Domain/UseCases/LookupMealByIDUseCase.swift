import Foundation

protocol LookupMealByIDUseCase {
    func execute(id: String) async throws -> Meal?
}

struct LookupMealByIDUseCaseImpl: LookupMealByIDUseCase {
    private let repository: MealRepository

    init(repository: MealRepository) {
        self.repository = repository
    }

    func execute(id: String) async throws -> Meal? {
        try await repository.lookupMeal(byID: id)
    }
}
