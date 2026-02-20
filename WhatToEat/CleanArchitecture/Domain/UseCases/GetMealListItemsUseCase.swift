import Foundation

protocol GetMealListItemsUseCase {
    func execute(type: MealListType) async throws -> MealListItems
}

struct GetMealListItemsUseCaseImpl: GetMealListItemsUseCase {
    private let repository: MealRepository

    init(repository: MealRepository) {
        self.repository = repository
    }

    func execute(type: MealListType) async throws -> MealListItems {
        try await repository.listItems(for: type)
    }
}
