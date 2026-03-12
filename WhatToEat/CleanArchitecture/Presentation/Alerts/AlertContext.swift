import SwiftUI

@MainActor
struct AlertContext {
    static let invalidData = AlertItem(
        title: Text("alert.server_error.title".localized),
        message: Text("alert.server_error.invalid_data.message".localized),
        dismissButton: .default(Text("common.ok".localized))
    )

    static let invalidResponse = AlertItem(
        title: Text("alert.server_error.title".localized),
        message: Text("alert.server_error.invalid_response.message".localized),
        dismissButton: .default(Text("common.ok".localized))
    )

    static let invalidURL = AlertItem(
        title: Text("alert.server_error.title".localized),
        message: Text("alert.server_error.invalid_url.message".localized),
        dismissButton: .default(Text("common.ok".localized))
    )

    static let somethingWentWrong = AlertItem(
        title: Text("alert.server_error.title".localized),
        message: Text("alert.server_error.something_wrong.message".localized),
        dismissButton: .default(Text("common.ok".localized))
    )

    static func appError(_ message: String, title: String = "alert.error.title".localized) -> AlertItem {
        AlertItem(
            title: Text(title),
            message: Text(message),
            dismissButton: .default(Text("common.ok".localized))
        )
    }
}
