import SwiftUI

struct MealListCell: View {
    @State private var viewModel: MealListCellViewModel
    let thumbnailSize: MealThumbnailSize
    let showsFavoriteButton: Bool

    private var tags: [String] { viewModel.meal.displayTags }
    private var displayedTags: [String] { Array(tags.prefix(2)) }

    init(
        meal: Meal,
        thumbnailSize: MealThumbnailSize,
        favoritesMealStore: FavoritesMealStore,
        showsFavoriteButton: Bool = true
    ) {
        _viewModel = State(initialValue: MealListCellViewModel(meal: meal, favoritesMealStore: favoritesMealStore))
        self.thumbnailSize = thumbnailSize
        self.showsFavoriteButton = showsFavoriteButton
    }

    var body: some View {
        ZStack(alignment: .leading) {

            CachedRemoteImage(url: viewModel.meal.thumbnailURL(size: thumbnailSize))
                .aspectRatio(contentMode: .fill)
                .frame(height: 180)
                .clipped()

            MealImageOverlayGradient()

            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.meal.strMeal)
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

            VStack {
                HStack {
                    Spacer()
                    if showsFavoriteButton {
                        FavoriteBadgeButton(
                            isFavorite: viewModel.isFavorite,
                            isDisabled: viewModel.isUpdatingFavorite,
                            onToggle: {
                                await viewModel.toggleFavorite()
                            }
                        )
                    }
                }
                Spacer()
            }
            .padding(12)
        }
        .frame(height: 180)
        .clipShape(.rect(cornerRadius: 16))
        .task(id: viewModel.meal.idMeal) {
            guard showsFavoriteButton else { return }
            viewModel.startObservingFavorites()
        }
        .onDisappear {
            guard showsFavoriteButton else { return }
            viewModel.stopObservingFavorites()
        }
    }
}
