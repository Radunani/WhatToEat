import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            ProgressView()
                .scaleEffect(1.2)
        }
    }
}
