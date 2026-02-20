import SwiftUI

struct AlertItem: Identifiable {
    let id: UUID = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
}

struct AlertContext {
    // MARK: Network
    static let invalidData = AlertItem(
        title: Text("Server Error"),
        message: Text("Data received from the server is invalid. Please try again later."),
        dismissButton: .default(Text("OK"))
    )
    
    static let invalidResponse = AlertItem(
        title: Text("Server Error"),
        message: Text("Invalid response from the server. Please try again later."),
        dismissButton: .default(Text("OK"))
    )
    
    static let invalidURL = AlertItem(
        title: Text("Server Error"),
        message: Text("Invalid URL. Please try again later."),
        dismissButton: .default(Text("OK"))
    )
    
    static let somethingWentWrong = AlertItem(
        title: Text("Server Error"),
        message: Text("Something went wrong. Please try again later."),
        dismissButton: .default(Text("OK"))
    )
}
