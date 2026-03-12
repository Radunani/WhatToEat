import Foundation

final class AppContainer: AppContainerProtocol {
    private lazy var networkClient: NetworkClient = NetworkManager.shared
    private lazy var mealService: MealDBServiceProtocol = MealDBAPIService(networkClient: networkClient)
    private lazy var remoteDataSource: MealRemoteDataSource = MealRemoteDataSourceImpl(service: mealService)
    private lazy var mealRepository: MealRepository = MealRepositoryImpl(remoteDataSource: remoteDataSource)
    @MainActor
    private lazy var favoritesMealStore: FavoritesMealStore = CoreDataFavoritesManager()

    @MainActor
    func makeMealOfTheDayViewModel() -> MealOfTheDayViewModel {
        let useCase = GetRandomMealUseCaseImpl(repository: mealRepository)
        return MealOfTheDayViewModel(getRandomMealUseCase: useCase)
    }

    @MainActor
    func makeMealsViewModel() -> MealsViewModel {
        let searchUseCase = SearchMealsUseCaseImpl(repository: mealRepository)
        let mealListItemsUseCase = GetMealListItemsUseCaseImpl(repository: mealRepository)
        let filterMealsUseCase = FilterMealsUseCaseImpl(repository: mealRepository)
        let lookupMealByIDUseCase = LookupMealByIDUseCaseImpl(repository: mealRepository)
        return MealsViewModel(
            searchMealsUseCase: searchUseCase,
            getMealListItemsUseCase: mealListItemsUseCase,
            filterMealsUseCase: filterMealsUseCase,
            lookupMealByIDUseCase: lookupMealByIDUseCase
        )
    }

    @MainActor
    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(favoritesMealStore: favoritesMealStore)
    }

    @MainActor
    func makeFavoritesMealStore() -> FavoritesMealStore {
        favoritesMealStore
    }
}
