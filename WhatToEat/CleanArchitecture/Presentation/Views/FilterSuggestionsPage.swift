import SwiftUI

struct FilterSuggestionsPage: View {
    @Bindable var viewModel: FilterSuggestionsPageViewModel
    let onSelect: (String) -> Void

    var body: some View {
        List {
            if !viewModel.filteredSuggestions.isEmpty {
                if viewModel.mode == .ingredient {
                    ForEach(viewModel.ingredientSuggestionSections) { section in
                        Section(section.title) {
                            ForEach(section.items, id: \.self) { value in
                                Button(value) {
                                    onSelect(value)
                                }
                            }
                        }
                    }
                } else {
                    Section("section.suggestions".localized) {
                        ForEach(viewModel.filteredSuggestions, id: \.self) { value in
                            Button(value) {
                                onSelect(value)
                            }
                        }
                    }
                }
            }

            if !viewModel.isLoading && viewModel.filteredSuggestions.isEmpty {
                Section {
                    NoResultsView(item: NoResultsContext.suggestions(for: viewModel.mode))
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }
}
