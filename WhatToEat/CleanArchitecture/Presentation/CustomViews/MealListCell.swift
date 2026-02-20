import SwiftUI

struct MealListCell: View {

    let meal: Meal
    let thumbnailSize: MealThumbnailSize

    private var tags: [String] {
        let raw = [meal.strArea, meal.strCategory].compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        return raw.filter { !$0.isEmpty }
    }

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

                HStack(spacing: 8) {
                    ForEach(Array(tags.prefix(2).enumerated()), id: \.offset) { index, tag in
                        MealTag(
                            text: tag,
                            color: index == 0 ? .red : .orange
                        )
                    }
                }
            }
            .padding(12)
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct MealTag: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.70))
            .clipShape(Capsule())
    }
}

#Preview {
    MealListCell(meal: MockData.randomMeals.first!, thumbnailSize: .medium)
}
