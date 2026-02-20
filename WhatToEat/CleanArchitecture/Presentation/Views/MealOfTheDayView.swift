import SwiftUI

struct MealOfTheDayView: View {
    @StateObject private var viewModel: MealOfTheDayViewModel
    private let thumbnailSize: MealThumbnailSize
    
    init(viewModel: MealOfTheDayViewModel, thumbnailSize: MealThumbnailSize = .medium) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.thumbnailSize = thumbnailSize
    }

    private var alertBinding: Binding<AlertItem?> {
        Binding(
            get: { viewModel.alertItem },
            set: { _ in }
        )
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.mealEntries) { entry in
                    MealListCell(meal: entry.meal, thumbnailSize: thumbnailSize)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Meal of the day")
            .refreshable {
                await viewModel.refreshMeals()
            }
            .task() {
                for await meal in viewModel.liveMealOfTheDay {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.push(meal)
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingView()
                }
            }
            .alert(item: alertBinding) { alertItem in
                Alert(
                    title: alertItem.title,
                    message: alertItem.message,
                    dismissButton: alertItem.dismissButton
                )
            }
        }
    }

    private func mealCard(_ entry: MealFeedEntry) -> some View {
        CachedRemoteImage(url: entry.meal.thumbnailURL(size: thumbnailSize))
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 180)
            .clipped()
            .cornerRadius(8)
            .listRowSeparator(.hidden)
            .overlay(alignment: .bottomLeading) {
                titleOverlay(entry)
            }
    }

    private func titleOverlay(_ entry: MealFeedEntry) -> some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(.ultraThinMaterial)

            Text(entry.meal.strMeal)
                .font(.title2)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50, alignment: .leading)
        .clipShape(
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 0,
                    bottomLeading: 8,
                    bottomTrailing: 8,
                    topTrailing: 0
                )
            )
        )
    }
}

#Preview {
    MealOfTheDayView(viewModel: AppContainer().makeMealOfTheDayViewModel())
}
