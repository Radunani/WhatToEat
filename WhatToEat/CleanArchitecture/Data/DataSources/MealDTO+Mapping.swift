import Foundation

extension MealDTO {
    func toDomain() -> Meal {
        Meal(
            idMeal: idMeal,
            strMeal: strMeal,
            strMealAlternate: strMealAlternate,
            strCategory: strCategory,
            strArea: strArea,
            strInstructions: strInstructions,
            strMealThumb: strMealThumb,
            strTags: strTags,
            strYoutube: strYoutube,
            strSource: strSource,
            strImageSource: strImageSource,
            strCreativeCommonsConfirmed: strCreativeCommonsConfirmed,
            dateModified: dateModified,
            ingredients: ingredients.map { MealIngredient(ingredient: $0.ingredient, measure: $0.measure) }
        )
    }
}

extension MealCategoryDTO {
    func toDomain() -> MealCategory {
        MealCategory(
            idCategory: idCategory,
            strCategory: strCategory,
            strCategoryThumb: strCategoryThumb,
            strCategoryDescription: strCategoryDescription
        )
    }
}

extension FilteredMealDTO {
    func toDomain() -> FilteredMeal {
        FilteredMeal(
            idMeal: idMeal,
            strMeal: strMeal,
            strMealThumb: strMealThumb
        )
    }
}
