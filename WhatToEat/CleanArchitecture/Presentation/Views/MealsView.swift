import SwiftUI

struct MealsView: View {
    @StateObject private var viewModel: MealsViewModel
    @State private var query = "Arrabiata"

    init(viewModel: MealsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                if !viewModel.categories.isEmpty {
                    Section("Categories") {
                        ForEach(viewModel.categories) { category in
                            Text(category.strCategory)
                        }
                    }
                }

                Section("Meals") {
                    ForEach(viewModel.meals) { meal in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(meal.strMeal)
                            Text(meal.strArea)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .searchable(text: $query, prompt: "Search meals by name")
            .onSubmit(of: .search) {
                Task { await viewModel.search(query: query) }
            }
            .navigationTitle("Meals")
            .task {
                await viewModel.loadInitialData()
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { _ in }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    MealsView(viewModel: AppContainer().makeMealsViewModel())
}

