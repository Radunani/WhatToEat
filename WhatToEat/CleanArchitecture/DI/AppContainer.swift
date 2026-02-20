import Foundation

protocol AppContainerProtocol {
    @MainActor
    func makeMealOfTheDayViewModel() -> MealOfTheDayViewModel
    @MainActor
    func makeMealsViewModel() -> MealsViewModel
    @MainActor
    func makeFavouritesViewModel() -> FavouritesViewModel
    func makeFavoritesMealStore() -> FavoritesMealStore
}

final class AppContainer: AppContainerProtocol {
    private lazy var networkClient: NetworkClient = NetworkManager.shared
    private lazy var mealService: MealDBServiceProtocol = MealDBAPIService(networkClient: networkClient)
    private lazy var remoteDataSource: MealRemoteDataSource = MealRemoteDataSourceImpl(service: mealService)
    private lazy var mealRepository: MealRepository = MealRepositoryImpl(remoteDataSource: remoteDataSource)
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
    func makeFavouritesViewModel() -> FavouritesViewModel {
        FavouritesViewModel(favoritesMealStore: favoritesMealStore)
    }

    func makeFavoritesMealStore() -> FavoritesMealStore {
        favoritesMealStore
    }
}
