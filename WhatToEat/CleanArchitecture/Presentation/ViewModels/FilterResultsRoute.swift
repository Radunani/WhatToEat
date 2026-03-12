import Foundation

struct FilterResultsRoute: Identifiable, Hashable {
    let mode: MealsFilterMode
    let value: String

    var id: String { "\(mode.rawValue)::\(value)" }
    var title: String {
        "filter.route.title"
            .localized
            .replacing("%@", with: mode.title, maxReplacements: 1)
            .replacing("%@", with: value, maxReplacements: 1)
    }
}
