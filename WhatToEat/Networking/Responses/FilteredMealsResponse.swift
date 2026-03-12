import Foundation

struct FilteredMealsResponse: Decodable {
    let meals: [FilteredMealDTO]?
}
