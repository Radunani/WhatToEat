import SwiftUI

struct MealDetailsHeaderView: View {
    let meal: Meal
    let displayedTags: [String]
    let isFavorite: Bool
    let isUpdatingFavorite: Bool
    let onToggleFavorite: () async -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            CachedRemoteImage(url: meal.thumbnailURL(size: .large))
                .frame(height: 360)
                .clipped()

            MealImageOverlayGradient()

            VStack {
                HStack {
                    Spacer()
                    FavoriteBadgeButton(
                        isFavorite: isFavorite,
                        isDisabled: isUpdatingFavorite,
                        onToggle: onToggleFavorite
                    )
                }
                Spacer()
            }
            .padding(12)

            VStack(alignment: .leading, spacing: 8) {
                Text(meal.strMeal)
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                    .lineLimit(2)

                if !displayedTags.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(displayedTags.indices, id: \.self) { index in
                            MealTag(
                                text: displayedTags[index],
                                color: index == 0 ? .red : .orange
                            )
                        }
                    }
                }
            }
            .padding(12)
        }
        .frame(height: 360)
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal)
    }
}
