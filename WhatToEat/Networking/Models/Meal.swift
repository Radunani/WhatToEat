import Foundation

struct Meal: Decodable, Identifiable {
    let idMeal: String
    let strMeal: String
    let strMealAlternate: String?
    let strCategory: String
    let strArea: String
    let strInstructions: String?
    let strMealThumb: String?
    let strTags: String?
    let strYoutube: String?
    let strSource: String?
    let strImageSource: String?
    let strCreativeCommonsConfirmed: String?
    let dateModified: String?
    let ingredients: [MealIngredient]

    var id: String { idMeal }

    private enum CodingKeys: String, CodingKey {
        case idMeal
        case strMeal
        case strMealAlternate
        case strCategory
        case strArea
        case strInstructions
        case strMealThumb
        case strTags
        case strYoutube
        case strSource
        case strImageSource
        case strCreativeCommonsConfirmed
        case dateModified
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        idMeal = try container.decode(String.self, forKey: .idMeal)
        strMeal = try container.decodeIfPresent(String.self, forKey: .strMeal) ?? "no_data"
        strMealAlternate = try container.decodeIfPresent(String.self, forKey: .strMealAlternate)
        strCategory = try container.decodeIfPresent(String.self, forKey: .strCategory) ?? "no_data"
        strArea = try container.decodeIfPresent(String.self, forKey: .strArea) ?? "no_data"
        strInstructions = try container.decodeIfPresent(String.self, forKey: .strInstructions)
        strMealThumb = try container.decodeIfPresent(String.self, forKey: .strMealThumb)
        strTags = try container.decodeIfPresent(String.self, forKey: .strTags)
        strYoutube = try container.decodeIfPresent(String.self, forKey: .strYoutube)
        strSource = try container.decodeIfPresent(String.self, forKey: .strSource)
        strImageSource = try container.decodeIfPresent(String.self, forKey: .strImageSource)
        strCreativeCommonsConfirmed = try container.decodeIfPresent(String.self, forKey: .strCreativeCommonsConfirmed)
        dateModified = try container.decodeIfPresent(String.self, forKey: .dateModified)

        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKey.self)
        var ingredientRows: [MealIngredient] = []

        for index in 1...20 {
            let ingredientKey = DynamicCodingKey("strIngredient\(index)")
            let measureKey = DynamicCodingKey("strMeasure\(index)")

            let rawIngredient = try dynamicContainer.decodeIfPresent(String.self, forKey: ingredientKey)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let rawMeasure = try dynamicContainer.decodeIfPresent(String.self, forKey: measureKey)?
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard let ingredient = rawIngredient, !ingredient.isEmpty else { continue }
            let measure = (rawMeasure?.isEmpty == false) ? rawMeasure : nil
            ingredientRows.append(MealIngredient(ingredient: ingredient, measure: measure))
        }

        ingredients = ingredientRows
    }
}
