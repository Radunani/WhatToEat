import Foundation

struct FilteredMeal: Decodable, Identifiable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String?

    var id: String { idMeal }
}

