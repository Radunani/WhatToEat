import Foundation

final class MealDBAPIService: MealDBServiceProtocol, @unchecked Sendable {
    private let networkClient: NetworkClient
    private let websiteBaseURL = URL(string: "https://www.themealdb.com")!

    init(networkClient: NetworkClient = NetworkManager.shared) {
        self.networkClient = networkClient
    }

    func searchMeals(byName name: String) async throws -> [MealDTO] {
        let response: MealsResponse = try await request(.searchByName(name))
        return response.meals ?? []
    }

    func listMeals(byFirstLetter letter: Character) async throws -> [MealDTO] {
        guard String(letter).count == 1, String(letter).rangeOfCharacter(from: .letters) != nil else {
            throw CustomError.invalidData
        }

        let response: MealsResponse = try await request(.listByFirstLetter(letter))
        return response.meals ?? []
    }

    func lookupMeal(byID id: String) async throws -> MealDTO? {
        let response: MealsResponse = try await request(.lookupByID(id))
        return response.meals?.first
    }

    func randomMeal() async throws -> MealDTO? {
        let response: MealsResponse = try await request(.random)
        return response.meals?.first
    }

    func listMealCategories() async throws -> [MealCategoryDTO] {
        let response: CategoriesResponse = try await request(.categories)
        return response.categories
    }

    func listItems(for type: MealListType) async throws -> MealListItems {
        switch type {
        case .category:
            let response: CategoryListResponse = try await request(.list(type))
            return .categories((response.meals ?? []).map(\.strCategory))
        case .area:
            let response: AreaListResponse = try await request(.list(type))
            return .areas((response.meals ?? []).map(\.strArea))
        case .ingredient:
            let response: IngredientListResponse = try await request(.list(type))
            return .ingredients((response.meals ?? []).map {
                Ingredient(
                    idIngredient: $0.idIngredient,
                    strIngredient: $0.strIngredient,
                    strDescription: $0.strDescription,
                    strType: $0.strType,
                    strThumb: $0.strThumb
                )
            })
        }
    }

    func filterMeals(by filter: MealFilter) async throws -> [FilteredMealDTO] {
        let response: FilteredMealsResponse = try await request(.filter(filter))
        return response.meals ?? []
    }

    func mealThumbnailURL(from value: String, size: MealThumbnailSize) -> URL? {
        let baseURL: URL
        if let url = URL(string: value), url.scheme != nil {
            baseURL = url
        } else {
            let normalizedPath = value.hasPrefix("/") ? String(value.dropFirst()) : value
            baseURL = websiteBaseURL.appendingPathComponent(normalizedPath)
        }

        return baseURL.appendingPathComponent(size.rawValue)
    }

    func ingredientImageURL(for ingredient: String, size: IngredientImageSize) -> URL? {
        let base = websiteBaseURL
            .appendingPathComponent("images")
            .appendingPathComponent("ingredients")
        let fileName = "\(ingredient)\(size.suffix).png"
        return base.appendingPathComponent(fileName)
    }

    private func request<T: Decodable>(_ endpoint: MealDBEndpoint) async throws -> T {
        try await networkClient.get(endpoint.path, queryItems: endpoint.queryItems)
    }
}
