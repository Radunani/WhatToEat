import SwiftUI

private enum FavoritesEvents {
    static let didChange = Notification.Name("FavoritesMealStore.didChange")
}

struct MealListCell: View {

    let meal: Meal
    let thumbnailSize: MealThumbnailSize
    let favoritesMealStore: FavoritesMealStore
    @State private var isFavorite = false
    @State private var isUpdatingFavorite = false
    @State private var favoriteStateRequestID = UUID()

    private var tags: [String] { meal.displayTags }

    var body: some View {
        ZStack(alignment: .leading) {

            CachedRemoteImage(url: meal.thumbnailURL(size: thumbnailSize))
                .aspectRatio(contentMode: .fill)
                .frame(height: 180)
                .clipped()

            LinearGradient(
                colors: [
                    .black.opacity(0.05),
                    .black.opacity(0.50),
                    .black.opacity(0.85)
                ],
                startPoint: .trailing,
                endPoint: .leading
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(meal.strMeal)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(2)

                if !tags.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(Array(tags.prefix(2).enumerated()), id: \.offset) { index, tag in
                            MealTag(
                                text: tag,
                                color: index == 0 ? .red : .orange
                            )
                        }
                    }
                }
            }
            .padding(12)

            VStack {
                HStack {
                    Spacer()
                    Button {
                        Task { await toggleFavorite() }
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(isFavorite ? .red : .white)
                            .font(.system(size: 18, weight: .semibold))
                            .padding(10)
                            .background(.black.opacity(0.35), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .disabled(isUpdatingFavorite)
                    .accessibilityIdentifier("mealcell.favorite")
                    .accessibilityLabel(isFavorite ? "Remove from favourites" : "Add to favourites")
                }
                Spacer()
            }
            .padding(12)
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .task(id: meal.idMeal) {
            await loadFavoriteState()
        }
        .onReceive(NotificationCenter.default.publisher(for: FavoritesEvents.didChange)) { notification in
            let idMeal = notification.userInfo?["idMeal"] as? String
            guard idMeal == nil || idMeal == meal.idMeal else { return }
            Task { await loadFavoriteState() }
        }
    }

    @MainActor
    private func loadFavoriteState() async {
        let requestID = UUID()
        favoriteStateRequestID = requestID

        do {
            let currentValue = try await favoritesMealStore.isFavorite(idMeal: meal.idMeal)
            guard requestID == favoriteStateRequestID else { return }
            isFavorite = currentValue
        } catch {
            guard requestID == favoriteStateRequestID else { return }
        }
    }

    @MainActor
    private func toggleFavorite() async {
        guard !isUpdatingFavorite else { return }
        favoriteStateRequestID = UUID()
        isUpdatingFavorite = true
        defer { isUpdatingFavorite = false }

        let willBeFavorite = !isFavorite
        isFavorite = willBeFavorite

        do {
            if willBeFavorite {
                try await favoritesMealStore.addToFavorites(meal)
            } else {
                try await favoritesMealStore.removeFromFavorites(idMeal: meal.idMeal)
            }
            NotificationCenter.default.post(
                name: FavoritesEvents.didChange,
                object: nil,
                userInfo: ["idMeal": meal.idMeal]
            )
        } catch {
            isFavorite.toggle()
        }
    }
}

#Preview {
    MealListCell(
        meal: MockData.randomMeals.first!,
        thumbnailSize: .medium,
        favoritesMealStore: CoreDataFavoritesManager()
    )
}
