//
//  WhatToEatApp.swift
//  WhatToEat
//
//  Created by Radu Nani on 17.02.2026.
//

import SwiftUI

@main
struct WhatToEatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
}
