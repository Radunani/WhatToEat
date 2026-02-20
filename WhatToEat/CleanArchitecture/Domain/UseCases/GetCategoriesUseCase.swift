import Foundation

protocol GetCategoriesUseCase {
    func execute() async throws -> [MealCategory]
}

struct GetCategoriesUseCaseImpl: GetCategoriesUseCase {
    private let repository: MealRepository

    init(repository: MealRepository) {
        self.repository = repository
    }

    func execute() async throws -> [MealCategory] {
        try await repository.listCategories()
    }
}

