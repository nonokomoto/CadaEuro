//
//  ContentView.swift
//  CadaEuro
//
//  Created by NeyCarvalho on 30/05/2025.
//

import SwiftUI
import SwiftData
import CadaEuroUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        // ✅ Wrapper que usa ShoppingListView como view principal
        ShoppingListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
        .themeProvider(.preview)
}
