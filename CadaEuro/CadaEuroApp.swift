//
//  CadaEuroApp.swift
//  CadaEuro
//
//  Created by NeyCarvalho on 30/05/2025.
//

import SwiftUI
import SwiftData
import CadaEuroUI

@main
struct CadaEuroApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .cadaEuroTheme() // ✅ Injeção única do tema aqui
        }
        .modelContainer(sharedModelContainer)
    }
}
