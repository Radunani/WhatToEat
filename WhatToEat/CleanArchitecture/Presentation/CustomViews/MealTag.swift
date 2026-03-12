import SwiftUI

struct MealTag: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.70))
            .clipShape(.capsule)
    }
}
