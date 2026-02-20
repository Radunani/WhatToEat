import CoreData
import Foundation

enum FavoritesPersistenceError: Error {
    case invalidEntity
}

actor CoreDataFavoritesManager: FavoritesMealStore {
    private enum Entity {
        static let name = "FavoriteMeal"
        static let idMeal = "idMeal"
        static let strMeal = "strMeal"
        static let strCategory = "strCategory"
        static let strArea = "strArea"
        static let ingredientsData = "ingredientsData"
        static let strInstructions = "strInstructions"
        static let strMealThumb = "strMealThumb"
        static let strYoutube = "strYoutube"
        static let orderIndex = "orderIndex"
    }

    private let container: NSPersistentContainer

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
    }

    func fetchFavorites() async throws -> [Meal] {
        try await context.performAsync {
            let request = NSFetchRequest<NSManagedObject>(entityName: Entity.name)
            request.sortDescriptors = [NSSortDescriptor(key: Entity.orderIndex, ascending: false)]
            return try self.context.fetch(request).map(Self.mapToMeal)
        }
    }

    func addToFavorites(_ meal: Meal) async throws {
        try await context.performAsync {
            let request = NSFetchRequest<NSManagedObject>(entityName: Entity.name)
            request.predicate = NSPredicate(format: "%K == %@", Entity.idMeal, meal.idMeal)
            request.fetchLimit = 1

            if let existing = try self.context.fetch(request).first {
                Self.update(existing, with: meal)
            } else {
                guard let entity = NSEntityDescription.entity(forEntityName: Entity.name, in: self.context) else {
                    throw FavoritesPersistenceError.invalidEntity
                }

                let object = NSManagedObject(entity: entity, insertInto: self.context)
                Self.update(object, with: meal)
                object.setValue(self.nextOrderIndex(), forKey: Entity.orderIndex)
            }

            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }

    func removeFromFavorites(idMeal: String) async throws {
        try await context.performAsync {
            let request = NSFetchRequest<NSManagedObject>(entityName: Entity.name)
            request.predicate = NSPredicate(format: "%K == %@", Entity.idMeal, idMeal)

            let matches = try self.context.fetch(request)
            for item in matches {
                self.context.delete(item)
            }

            try self.reindexFavorites()
            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }

    func reorderFavorites(from source: IndexSet, to destination: Int) async throws -> [Meal] {
        try await context.performAsync {
            let request = NSFetchRequest<NSManagedObject>(entityName: Entity.name)
            request.sortDescriptors = [NSSortDescriptor(key: Entity.orderIndex, ascending: false)]

            var favorites = try self.context.fetch(request)
            let movingItems = source.sorted(by: >).map { favorites.remove(at: $0) }
            var insertionIndex = destination
            for index in source where index < destination {
                insertionIndex -= 1
            }
            favorites.insert(contentsOf: movingItems.reversed(), at: insertionIndex)

            let topIndex = Int64(max(0, favorites.count - 1))
            for (index, object) in favorites.enumerated() {
                object.setValue(topIndex - Int64(index), forKey: Entity.orderIndex)
            }

            if self.context.hasChanges {
                try self.context.save()
            }

            return favorites.map(Self.mapToMeal)
        }
    }

    func isFavorite(idMeal: String) async throws -> Bool {
        try await context.performAsync {
            let request = NSFetchRequest<NSManagedObject>(entityName: Entity.name)
            request.predicate = NSPredicate(format: "%K == %@", Entity.idMeal, idMeal)
            request.fetchLimit = 1
            let count = try self.context.count(for: request)
            return count > 0
        }
    }

    private var context: NSManagedObjectContext {
        container.viewContext
    }

    private func nextOrderIndex() -> Int64 {
        let request = NSFetchRequest<NSManagedObject>(entityName: Entity.name)
        request.sortDescriptors = [NSSortDescriptor(key: Entity.orderIndex, ascending: false)]
        request.fetchLimit = 1

        let last = try? context.fetch(request).first
        let current = last?.value(forKey: Entity.orderIndex) as? Int64 ?? -1
        return current + 1
    }

    private func reindexFavorites() throws {
        let request = NSFetchRequest<NSManagedObject>(entityName: Entity.name)
        request.sortDescriptors = [NSSortDescriptor(key: Entity.orderIndex, ascending: true)]

        let items = try context.fetch(request)
        for (index, item) in items.enumerated() {
            item.setValue(Int64(index), forKey: Entity.orderIndex)
        }
    }

    private static func update(_ object: NSManagedObject, with meal: Meal) {
        object.setValue(meal.idMeal, forKey: Entity.idMeal)
        object.setValue(meal.strMeal, forKey: Entity.strMeal)
        object.setValue(meal.strCategory, forKey: Entity.strCategory)
        object.setValue(meal.strArea, forKey: Entity.strArea)
        object.setValue(encodeIngredients(meal.ingredients), forKey: Entity.ingredientsData)
        object.setValue(meal.strInstructions, forKey: Entity.strInstructions)
        object.setValue(meal.strMealThumb, forKey: Entity.strMealThumb)
        object.setValue(meal.strYoutube, forKey: Entity.strYoutube)
    }

    private static func mapToMeal(_ object: NSManagedObject) -> Meal {
        let idMeal = object.value(forKey: Entity.idMeal) as? String ?? ""
        let strMeal = object.value(forKey: Entity.strMeal) as? String ?? ""
        let strCategory = object.value(forKey: Entity.strCategory) as? String ?? ""
        let strArea = object.value(forKey: Entity.strArea) as? String ?? ""
        let ingredientsData = object.value(forKey: Entity.ingredientsData) as? Data
        let strInstructions = object.value(forKey: Entity.strInstructions) as? String ?? ""
        let strMealThumb = object.value(forKey: Entity.strMealThumb) as? String
        let strYoutube = object.value(forKey: Entity.strYoutube) as? String

        return Meal(
            idMeal: idMeal,
            strMeal: strMeal,
            strMealAlternate: nil,
            strCategory: strCategory,
            strArea: strArea,
            strInstructions: strInstructions,
            strMealThumb: strMealThumb,
            strTags: nil,
            strYoutube: strYoutube,
            strSource: nil,
            strImageSource: nil,
            strCreativeCommonsConfirmed: nil,
            dateModified: nil,
            ingredients: decodeIngredients(from: ingredientsData)
        )
    }

    private static func encodeIngredients(_ ingredients: [MealIngredient]) -> Data? {
        try? JSONEncoder().encode(ingredients)
    }

    private static func decodeIngredients(from data: Data?) -> [MealIngredient] {
        guard let data else { return [] }
        return (try? JSONDecoder().decode([MealIngredient].self, from: data)) ?? []
    }
}
