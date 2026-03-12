import SwiftUI

struct MealDetailsView: View {
    let meal: Meal
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: MealDetailsViewModel
    private let onClose: (() -> Void)?
    private var displayedTags: [String] { Array(meal.displayTags.prefix(2)) }

    init(
        meal: Meal,
        favoritesMealStore: FavoritesMealStore,
        onClose: (() -> Void)? = nil
    ) {
        self.meal = meal
        _viewModel = State(initialValue: MealDetailsViewModel(meal: meal, favoritesMealStore: favoritesMealStore))
        self.onClose = onClose
    }

    private var alertBinding: Binding<AlertItem?> {
        Binding(
            get: { viewModel.alertItem },
            set: { _ in viewModel.clearAlert() }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                MealDetailsHeaderView(
                    meal: meal,
                    displayedTags: displayedTags,
                    isFavorite: viewModel.isFavorite,
                    isUpdatingFavorite: viewModel.isUpdatingFavorite,
                    onToggleFavorite: {
                        await viewModel.toggleFavorite()
                    }
                )

                if let youtubeURL = youtubeURL {
                    Button {
                        openURL(youtubeURL)
                    } label: {
                        Label("meal_details.watch_video".localized, systemImage: "play.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .tint(.accent)
                    .buttonStyle(.bordered)
                    .padding(.horizontal)
                }

                if !meal.ingredients.isEmpty {
                    sectionTitle("meal_details.ingredients".localized)
                        .padding(.horizontal)

                    VStack(spacing: 8) {
                        ForEach(meal.ingredients.indices, id: \.self) { index in
                            let row = meal.ingredients[index]
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("• \(row.ingredient)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                if let measure = row.measure, !measure.isEmpty {
                                    Text(measure)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding(.horizontal)
                }

                if !meal.strInstructions.isEmpty {
                    sectionTitle("meal_details.instructions".localized)
                        .padding(.horizontal)

                    Text(meal.strInstructions)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle("meal_details.navigation_title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {

            ToolbarItem(placement: .topBarTrailing) {
                Button("common.close".localized, systemImage: "xmark") {
                    if let onClose {
                        onClose()
                    } else {
                        dismiss()
                    }
                }
                .labelStyle(.iconOnly)
            }
        }
        .task {
            await viewModel.loadFavoriteState()
        }
        .appAlert(item: alertBinding)
    }

    private var youtubeURL: URL? {
        guard let raw = meal.strYoutube,
              let url = URL(string: raw),
              url.scheme != nil else {
            return nil
        }
        return url
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(.primary)
    }
}
