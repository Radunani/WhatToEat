import Foundation

protocol AppContainerProtocol {
    @MainActor
    func makeMealOfTheDayViewModel() -> MealOfTheDayViewModel
    @MainActor
    func makeMealsViewModel() -> MealsViewModel
}

final class AppContainer: AppContainerProtocol {
    private lazy var networkClient: NetworkClient = NetworkManager.shared
    private lazy var mealService: MealDBServiceProtocol = MealDBAPIService(networkClient: networkClient)
    private lazy var remoteDataSource: MealRemoteDataSource = MealRemoteDataSourceImpl(service: mealService)
    private lazy var mealRepository: MealRepository = MealRepositoryImpl(remoteDataSource: remoteDataSource)

    @MainActor
    func makeMealOfTheDayViewModel() -> MealOfTheDayViewModel {
        let useCase = GetRandomMealUseCaseImpl(repository: mealRepository)
        return MealOfTheDayViewModel(getRandomMealUseCase: useCase)
    }

    @MainActor
    func makeMealsViewModel() -> MealsViewModel {
        let searchUseCase = SearchMealsUseCaseImpl(repository: mealRepository)
        let categoriesUseCase = GetCategoriesUseCaseImpl(repository: mealRepository)
        return MealsViewModel(
            searchMealsUseCase: searchUseCase,
            getCategoriesUseCase: categoriesUseCase
        )
    }
}
