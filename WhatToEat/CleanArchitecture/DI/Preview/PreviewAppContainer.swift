import Foundation

struct MockData {
    static let randomMeals: [Meal] = [
        meal(id: "52771", name: "Spicy Arrabiata Penne", category: "Vegetarian", area: "Italian", imageName: "ustsqw1468250014.jpg"),
        meal(id: "52959", name: "Baked salmon with fennel & tomatoes", category: "Seafood", area: "British", imageName: "1548772327.jpg"),
        meal(id: "53026", name: "Tuna and Egg Briks", category: "Seafood", area: "Tunisian", imageName: "2dsltq1560461468.jpg")
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

    private static func meal(
        id: String,
        name: String,
        category: String,
        area: String,
        imageName: String
    ) -> Meal {
        let json = """
        {
          "idMeal": "\(id)",
          "strMeal": "\(name)",
          "strCategory": "\(category)",
          "strArea": "\(area)",
          "strMealThumb": "https://www.themealdb.com/images/media/meals/\(imageName)",
          "strIngredient1": "olive oil",
          "strMeasure1": "1 tbsp"
        }
        """

        guard let data = json.data(using: .utf8),
              let meal = try? JSONDecoder().decode(Meal.self, from: data) else {
            fatalError("Invalid preview meal fixture")
        }

        return meal
    }
}
