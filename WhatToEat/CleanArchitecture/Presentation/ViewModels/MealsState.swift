import Foundation

struct MealsState {
    var selectedMode: MealsFilterMode = .name
    var selectedFilterRoute: FilterResultsRoute?
    var selectedMeal: Meal?
}
