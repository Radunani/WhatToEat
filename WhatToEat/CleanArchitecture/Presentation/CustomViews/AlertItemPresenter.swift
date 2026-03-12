import SwiftUI

extension View {
    func appAlert(item: Binding<AlertItem?>) -> some View {
        alert(item: item) { alertItem in
            Alert(
                title: alertItem.title,
                message: alertItem.message,
                dismissButton: alertItem.dismissButton
            )
        }
    }
}
