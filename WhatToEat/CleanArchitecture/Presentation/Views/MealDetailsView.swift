import SwiftUI

struct MealDetailsView: View {
    let meal: Meal
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: MealDetailsViewModel
    private let onClose: (() -> Void)?

    init(
        meal: Meal,
        favoritesMealStore: FavoritesMealStore = CoreDataFavoritesManager(),
        onClose: (() -> Void)? = nil
    ) {
        self.meal = meal
        _viewModel = StateObject(wrappedValue: MealDetailsViewModel(meal: meal, favoritesMealStore: favoritesMealStore))
        self.onClose = onClose
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                if let youtubeURL = youtubeURL {
                    Button {
                        openURL(youtubeURL)
                    } label: {
                        Label("Watch Video", systemImage: "play.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                }

                if !meal.ingredients.isEmpty {
                    sectionTitle("Ingredients")
                        .padding(.horizontal)

                    VStack(spacing: 8) {
                        ForEach(Array(meal.ingredients.enumerated()), id: \.offset) { _, row in
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
                    sectionTitle("Instructions")
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
        .navigationTitle("Meal Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    Task { await viewModel.toggleFavorite() }
                } label: {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                }
                .disabled(viewModel.isUpdatingFavorite)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let onClose {
                        onClose()
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .task {
            await viewModel.loadFavoriteState()
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.clearError() }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            CachedRemoteImage(url: meal.thumbnailURL(size: .large))
                .aspectRatio(contentMode: .fill)
                .frame(height: 360)
                .clipped()

            LinearGradient(
                colors: [
                    .black.opacity(0.05),
                    .black.opacity(0.5),
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

                if !headerTags.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(Array(headerTags.prefix(2).enumerated()), id: \.offset) { index, tag in
                            MealTag(text: tag, color: index == 0 ? .red : .orange)
                        }
                    }
                }
            }
            .padding(12)
        }
        .frame(height: 360)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
    }

    private var youtubeURL: URL? {
        guard let raw = meal.strYoutube,
              let url = URL(string: raw),
              url.scheme != nil else {
            return nil
        }
        return url
    }

    private var headerTags: [String] {
        meal.displayTags
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(.primary)
    }
}

#Preview {
    MealDetailsView(meal: MockData.randomMeals.first!)
}
