import Foundation
import Observation

@MainActor
@Observable
final class MealOfTheDayViewModel {
    private(set) var meals: [Meal] = []
    private(set) var mealEntries: [MealFeedEntry] = []
    private(set) var isLoading = false
    private(set) var alertItem: AlertItem?
    
    @ObservationIgnored
    private let getRandomMealUseCase: GetRandomMealUseCase
    @ObservationIgnored
    private var liveFeedTask: Task<Void, Never>?
    @ObservationIgnored
    private var hasStartedInitialFeed = false
    
    init(getRandomMealUseCase: GetRandomMealUseCase) {
        self.getRandomMealUseCase = getRandomMealUseCase
    }
    
    var liveMealOfTheDay: LiveMealOfTheDay {
        LiveMealOfTheDay(intervalSeconds: 3, maxRequests: 4) { [weak self] in
            guard let self else { return nil }
            return try? await self.getRandomMealUseCase.execute()
        }
    }

    func startInitialFeedIfNeeded() {
        guard !hasStartedInitialFeed else { return }
        hasStartedInitialFeed = true
        startLiveFeed(reset: false)
    }

    func restartLiveFeed() {
        startLiveFeed(reset: true)
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

    func resetMeals() {
        meals.removeAll()
        mealEntries.removeAll()
    }
    
    func push(_ meal: Meal) {
        insert(meal)
    }
    
    private func insert(_ meal: Meal) {
        meals.insert(meal, at: 0)
        mealEntries.insert(MealFeedEntry(meal: meal), at: 0)
    }

    private func startLiveFeed(reset: Bool) {
        liveFeedTask?.cancel()
        if reset {
            resetMeals()
        }

        liveFeedTask = Task { [weak self] in
            guard let self else { return }
            for await meal in self.liveMealOfTheDay {
                if Task.isCancelled { return }
                self.push(meal)
            }
        }
    }

    deinit {
        liveFeedTask?.cancel()
    }
}
