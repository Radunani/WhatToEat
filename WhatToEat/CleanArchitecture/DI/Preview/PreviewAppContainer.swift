import Foundation

struct MockData {
    static let randomMeals: [Meal] = [
        meal(id: "52771", name: "Spicy Arrabiata Penne", category: "Vegetarian", area: "Italian", imageName: "ustsqw1468250014.jpg", strYoutube: "https://m.youtube.com/watch?v=kSKtb2Sv-_U"),
        meal(id: "52959", name: "Baked salmon with fennel & tomatoes", category: "Seafood", area: "British", imageName: "1548772327.jpg", strYoutube: "https://m.youtube.com/watch?v=kSKtb2Sv-_U"),
        meal(id: "53026", name: "Tuna and Egg Briks", category: "Seafood", area: "Tunisian", imageName: "2dsltq1560461468.jpg", strYoutube: "https://m.youtube.com/watch?v=kSKtb2Sv-_U")
    ]

    static let categories: [MealCategory] = [
        MealCategory(
            idCategory: "1",
            strCategory: "Beef",
            strCategoryThumb: "https://www.themealdb.com/images/category/beef.png",
            strCategoryDescription: "Beef dishes"
        ),
        MealCategory(
            idCategory: "2",
            strCategory: "Seafood",
            strCategoryThumb: "https://www.themealdb.com/images/category/seafood.png",
            strCategoryDescription: "Seafood dishes"
        ),
        MealCategory(
            idCategory: "3",
            strCategory: "Vegetarian",
            strCategoryThumb: "https://www.themealdb.com/images/category/vegetarian.png",
            strCategoryDescription: "Vegetarian dishes"
        )
    ]

    static let filteredMeals: [FilteredMeal] = [
        FilteredMeal(
            idMeal: "52944",
            strMeal: "Lasagne",
            strMealThumb: "https://www.themealdb.com/images/media/meals/wtsvxx1511296896.jpg"
        ),
        FilteredMeal(
            idMeal: "52945",
            strMeal: "Prawn Risotto",
            strMealThumb: "https://www.themealdb.com/images/media/meals/58oia61564916529.jpg"
        )
    ]

    static let filteredResultsRoute = FilterResultsRoute(mode: .category, value: "Seafood")

    static let categorySuggestions: [String] = [
        "Seafood",
        "Vegetarian",
        "Beef",
        "Dessert"
    ]

    static let areaSuggestions: [String] = [
        "Italian",
        "British",
        "Tunisian",
        "Mexican"
    ]

    static let ingredientSuggestions: [String] = [
        "Chicken",
        "Salmon",
        "Tomato",
        "Garlic"
    ]

    static func makeFavoritesMealStore() -> FavoritesMealStore {
        PreviewFavoritesMealStore(initialMeals: randomMeals)
    }

    private static func meal(
        id: String,
        name: String,
        category: String,
        area: String,
        imageName: String,
        strYoutube: String
    ) -> Meal {
        Meal(
            idMeal: id,
            strMeal: name,
            strMealAlternate: nil,
            strCategory: category,
            strArea: area,
            strInstructions: "Bring a large pot of water to a boil and cook the pasta. Build a quick tomato sauce with olive oil, garlic, tomatoes, herbs, salt and pepper.",
            strMealThumb: "https://www.themealdb.com/images/media/meals/\(imageName)",
            strTags: nil,
            strYoutube: strYoutube,
            strSource: nil,
            strImageSource: nil,
            strCreativeCommonsConfirmed: nil,
            dateModified: nil,
            ingredients: [
                MealIngredient(ingredient: "olive oil", measure: "1 tbsp")
            ]
        )
    }
}
