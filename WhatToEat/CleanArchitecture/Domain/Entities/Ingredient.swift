import Foundation

struct Ingredient: Identifiable, Hashable {
    let idIngredient: String?
    let strIngredient: String
    let strDescription: String?
    let strType: String?
    let strThumb: String?

    var id: String { idIngredient ?? strIngredient }
}
