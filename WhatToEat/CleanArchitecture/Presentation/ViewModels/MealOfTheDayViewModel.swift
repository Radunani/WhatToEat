import Foundation

struct MealFeedEntry: Identifiable {
    let id = UUID()
    let meal: Meal
}

@MainActor
final class MealOfTheDayViewModel: ObservableObject {
    @Published private(set) var meals: [Meal] = []
    @Published private(set) var mealEntries: [MealFeedEntry] = []
    @Published private(set) var isLoading = false
    @Published private(set) var alertItem: AlertItem?
    
    private let getRandomMealUseCase: GetRandomMealUseCase
    
    init(getRandomMealUseCase: GetRandomMealUseCase) {
        self.getRandomMealUseCase = getRandomMealUseCase
    }
    
    var liveMealOfTheDay: LiveMealOfTheDay {
        LiveMealOfTheDay(intervalSeconds: 3, maxRequests: 2) { [getRandomMealUseCase] in
            try? await getRandomMealUseCase.execute()
        }
    }
    
    func loadMeal() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let meal = try await getRandomMealUseCase.execute() else { return }
            insert(meal)
        } catch {
            if let error = error as? CustomError {
                switch error {
                case .invalidData:
                    alertItem = AlertContext.invalidData
                case .invalidURL:
                    alertItem = AlertContext.invalidURL
                case .invalidResponse:
                    alertItem = AlertContext.invalidResponse
                }
            } else {
                alertItem = AlertContext.somethingWentWrong
            }
        }
    }

    func refreshMeals() async {
        meals.removeAll()
        mealEntries.removeAll()
        await loadMeal()
    }
    
    func push(_ meal: Meal) {
        insert(meal)
    }
    
    private func insert(_ meal: Meal) {
        meals.insert(meal, at: 0)
        mealEntries.insert(MealFeedEntry(meal: meal), at: 0)
    }
}
