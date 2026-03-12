import Foundation

extension FilteredMeal {
    var asPreviewMeal: Meal {
        Meal(
            idMeal: idMeal,
            strMeal: strMeal,
            strMealAlternate: nil,
            strCategory: "",
            strArea: "",
            strInstructions: "",
            strMealThumb: strMealThumb,
            strTags: nil,
            strYoutube: nil,
            strSource: nil,
            strImageSource: nil,
            strCreativeCommonsConfirmed: nil,
            dateModified: nil,
            ingredients: []
        )
    }
}
