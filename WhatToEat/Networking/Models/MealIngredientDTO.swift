import Foundation

struct MealIngredientDTO: Codable, Hashable {
    let ingredient: String
    let measure: String?
}
