import SwiftUI

struct FavoriteBadgeButton: View {
    let isFavorite: Bool
    let isDisabled: Bool
    let onToggle: () async -> Void

    private var title: String {
        isFavorite
        ? "accessibility.remove_from_favorites".localized
        : "accessibility.add_to_favorites".localized
    }

    private var systemImage: String {
        isFavorite ? "heart.fill" : "heart"
    }

    var body: some View {
        Button(title, systemImage: systemImage) {
            Task { await onToggle() }
        }
        .labelStyle(.iconOnly)
        .foregroundStyle(isFavorite ? .red : .white)
        .font(.title3)
        .bold()
        .padding(10)
        .background(.black.opacity(0.35), in: .circle)
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityLabel(title)
    }
}
