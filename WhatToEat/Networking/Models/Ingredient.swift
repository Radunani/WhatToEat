import Foundation

struct Ingredient: Decodable, Identifiable {
    let idIngredient: String?
    let strIngredient: String
    let strDescription: String?
    let strType: String?
    let strThumb: String?

    var id: String { idIngredient ?? strIngredient }
}

