import SwiftUI

struct MealImageOverlayGradient: View {
    var body: some View {
        LinearGradient(
            colors: [
                .black.opacity(0.05),
                .black.opacity(0.50),
                .black.opacity(0.85)
            ],
            startPoint: .trailing,
            endPoint: .leading
        )
    }
}
