import Foundation

struct SuggestionSection: Identifiable, Hashable {
    let title: String
    let items: [String]

    var id: String { title }
}
