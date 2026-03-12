import Foundation

enum MealsAction {
    case onAppear
    case changeMode(MealsFilterMode)
    case selectSuggestion(String)
    case selectMeal(Meal)
    case setSelectedFilterRoute(FilterResultsRoute?)
    case setSelectedMeal(Meal?)
}
