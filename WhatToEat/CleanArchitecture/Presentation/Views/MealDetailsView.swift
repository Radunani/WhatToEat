import SwiftUI

struct MealDetailsView: View {
    let meal: Meal
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

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
                        ForEach(meal.ingredients, id: \.self) { row in
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
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
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

                HStack(spacing: 8) {
                    MealTag(text: meal.strArea, color: .red)
                    MealTag(text: meal.strCategory, color: .orange)
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

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(.primary)
    }
}

#Preview {
    MealDetailsView(meal: MockData.randomMeals.first!)
}
