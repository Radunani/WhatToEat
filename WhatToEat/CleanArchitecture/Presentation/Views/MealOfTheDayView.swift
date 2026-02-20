import SwiftUI

struct MealOfTheDayView: View {
    @StateObject private var viewModel: MealOfTheDayViewModel
    @Namespace private var transitionNamespace
    @State private var selectedMeal: Meal?
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
                    mealRow(entry)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Meal of the day")
            .listRowSeparator(.hidden)
            .refreshable {
                await viewModel.refreshMeals()
            }
            .task {
                for await meal in viewModel.liveMealOfTheDay {
                    withAnimation(.easeInOut(duration: 0.3)) {
//                        viewModel.push(meal)
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
            .navigationDestination(item: $selectedMeal) { meal in
                MealDetailsView(meal: meal)
                    .toolbar(.hidden, for: .tabBar)
                    .navigationTransition(.zoom(sourceID: meal.id, in: transitionNamespace))
                
            }
        }
    }
    
    private func mealRow(_ entry: MealFeedEntry) -> some View {
        Group {
            MealListCell(meal: entry.meal, thumbnailSize: thumbnailSize)
                .matchedTransitionSource(id: entry.meal.id, in: transitionNamespace)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedMeal = entry.meal
        }
    }
}

#Preview {
    MealOfTheDayView(viewModel: AppContainer().makeMealOfTheDayViewModel())
}
