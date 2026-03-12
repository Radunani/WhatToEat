import Foundation

struct FilteredMealDTO: Decodable, Identifiable, Hashable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String?

    var id: String { idMeal }
}
