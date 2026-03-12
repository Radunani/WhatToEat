import Foundation

struct IngredientListResponse: Decodable {
    let meals: [IngredientDTO]?
}
