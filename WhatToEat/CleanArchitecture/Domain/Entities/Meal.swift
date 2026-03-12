import Foundation

struct Meal: Identifiable, Hashable {
    let idMeal: String
    let strMeal: String
    let strMealAlternate: String?
    let strCategory: String
    let strArea: String
    let strInstructions: String
    let strMealThumb: String?
    let strTags: String?
    let strYoutube: String?
    let strSource: String?
    let strImageSource: String?
    let strCreativeCommonsConfirmed: String?
    let dateModified: String?
    let ingredients: [MealIngredient]

    var id: String { idMeal }
}
