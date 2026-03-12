import SwiftUI

struct NoResultsView: View {
    let item: NoResultsItem

    init(item: NoResultsItem = NoResultsContext.mealsByName) {
        self.item = item
    }

    var body: some View {
        ContentUnavailableView(
            item.title,
            systemImage: item.systemImage,
            description: Text(item.message)
        )
    }
}
