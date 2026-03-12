import Foundation

@MainActor
protocol GetMealListItemsUseCase {
    func execute(type: MealListType) async throws -> MealListItems
}
