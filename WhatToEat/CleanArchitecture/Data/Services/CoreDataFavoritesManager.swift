@preconcurrency import CoreData
import Foundation

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
    private var favoritesContinuations: [UUID: AsyncStream<[Meal]>.Continuation] = [:]

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
    }

    func fetchFavorites() async throws -> [Meal] {
        let context = self.context
        return try await context.performAsync {
            let request = NSFetchRequest<NSManagedObject>(entityName: Entity.name)
            request.sortDescriptors = [NSSortDescriptor(key: Entity.orderIndex, ascending: false)]
            return try context.fetch(request).map(Self.mapToMeal)
        }
    }

    func observeFavorites() async -> AsyncStream<[Meal]> {
        let id = UUID()
        return AsyncStream { continuation in
            Task { await self.registerContinuation(continuation, id: id) }
        }
    }

    func addToFavorites(_ meal: Meal) async throws {
        let context = self.context
        try await context.performAsync {
            let request = NSFetchRequest<NSManagedObject>(entityName: Entity.name)
            request.predicate = NSPredicate(format: "%K == %@", Entity.idMeal, meal.idMeal)
            request.fetchLimit = 1

            if let existing = try context.fetch(request).first {
                Self.update(existing, with: meal)
            } else {
                guard let entity = NSEntityDescription.entity(forEntityName: Entity.name, in: context) else {
                    throw FavoritesPersistenceError.invalidEntity
                }

                let object = NSManagedObject(entity: entity, insertInto: context)
                Self.update(object, with: meal)
                object.setValue(Self.nextOrderIndex(in: context), forKey: Entity.orderIndex)
            }

            if context.hasChanges {
                try context.save()
            }
        }

        await broadcastFavoritesSnapshot()
    }

    func removeFromFavorites(idMeal: String) async throws {
        let context = self.context
        try await context.performAsync {
            let request = NSFetchRequest<NSManagedObject>(entityName: Entity.name)
            request.predicate = NSPredicate(format: "%K == %@", Entity.idMeal, idMeal)

            let matches = try context.fetch(request)
            for item in matches {
                context.delete(item)
            }

            try Self.reindexFavorites(in: context)
            if context.hasChanges {
                try context.save()
            }
        }

        await broadcastFavoritesSnapshot()
    }

    func reorderFavorites(fromIndices source: [Int], toIndex destination: Int) async throws -> [Meal] {
        let context = self.context
        let reordered = try await context.performAsync {
            let request = NSFetchRequest<NSManagedObject>(entityName: Entity.name)
            request.sortDescriptors = [NSSortDescriptor(key: Entity.orderIndex, ascending: false)]

            var favorites = try context.fetch(request)
            let sortedSource = source.sorted()
            let movingItems = sortedSource.sorted(by: >).map { favorites.remove(at: $0) }
            var insertionIndex = destination
            for index in sortedSource where index < destination {
                insertionIndex -= 1
            }
            favorites.insert(contentsOf: movingItems.reversed(), at: insertionIndex)

            let topIndex = Int64(max(0, favorites.count - 1))
            for (index, object) in favorites.enumerated() {
                object.setValue(topIndex - Int64(index), forKey: Entity.orderIndex)
            }

            if context.hasChanges {
                try context.save()
            }

            return favorites.map(Self.mapToMeal)
        }

        await broadcastFavoritesSnapshot()
        return reordered
    }

    func isFavorite(idMeal: String) async throws -> Bool {
        let context = self.context
        return try await context.performAsync {
            let request = NSFetchRequest<NSManagedObject>(entityName: Entity.name)
            request.predicate = NSPredicate(format: "%K == %@", Entity.idMeal, idMeal)
            request.fetchLimit = 1
            let count = try context.count(for: request)
            return count > 0
        }
    }

    private var context: NSManagedObjectContext {
        container.viewContext
    }

    private func registerContinuation(_ continuation: AsyncStream<[Meal]>.Continuation, id: UUID) async {
        favoritesContinuations[id] = continuation
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeContinuation(id: id) }
        }
        await pushFavoritesSnapshot(to: continuation)
    }

    private func removeContinuation(id: UUID) {
        favoritesContinuations[id] = nil
    }

    private func broadcastFavoritesSnapshot() async {
        let favorites = (try? await fetchFavorites()) ?? []
        for continuation in favoritesContinuations.values {
            continuation.yield(favorites)
        }
    }

    private func pushFavoritesSnapshot(to continuation: AsyncStream<[Meal]>.Continuation) async {
        let favorites = (try? await fetchFavorites()) ?? []
        continuation.yield(favorites)
    }

    nonisolated private static func nextOrderIndex(in context: NSManagedObjectContext) -> Int64 {
        let request = NSFetchRequest<NSManagedObject>(entityName: Entity.name)
        request.sortDescriptors = [NSSortDescriptor(key: Entity.orderIndex, ascending: false)]
        request.fetchLimit = 1

        let last = try? context.fetch(request).first
        let current = last?.value(forKey: Entity.orderIndex) as? Int64 ?? -1
        return current + 1
    }

    nonisolated private static func reindexFavorites(in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<NSManagedObject>(entityName: Entity.name)
        request.sortDescriptors = [NSSortDescriptor(key: Entity.orderIndex, ascending: true)]

        let items = try context.fetch(request)
        for (index, item) in items.enumerated() {
            item.setValue(Int64(index), forKey: Entity.orderIndex)
        }
    }

    nonisolated private static func update(_ object: NSManagedObject, with meal: Meal) {
        object.setValue(meal.idMeal, forKey: Entity.idMeal)
        object.setValue(meal.strMeal, forKey: Entity.strMeal)
        object.setValue(meal.strCategory, forKey: Entity.strCategory)
        object.setValue(meal.strArea, forKey: Entity.strArea)
        object.setValue(encodeIngredients(meal.ingredients), forKey: Entity.ingredientsData)
        object.setValue(meal.strInstructions, forKey: Entity.strInstructions)
        object.setValue(meal.strMealThumb, forKey: Entity.strMealThumb)
        object.setValue(meal.strYoutube, forKey: Entity.strYoutube)
    }

    nonisolated private static func mapToMeal(_ object: NSManagedObject) -> Meal {
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

    nonisolated private static func encodeIngredients(_ ingredients: [MealIngredient]) -> Data? {
        try? JSONEncoder().encode(ingredients)
    }

    nonisolated private static func decodeIngredients(from data: Data?) -> [MealIngredient] {
        guard let data else { return [] }
        return (try? JSONDecoder().decode([MealIngredient].self, from: data)) ?? []
    }
}
