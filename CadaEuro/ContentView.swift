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
    @Environment(\.themeProvider) private var themeProvider
    @Query private var items: [Item]

    var body: some View {
        VStack(spacing: themeProvider.theme.spacing.lg) {
            Text("Hello World")
                .font(themeProvider.theme.typography.titleLarge)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
            
            Text("CadaEuro Theme Provider Funcionando!")
                .font(themeProvider.theme.typography.bodyLarge)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
            
            Text("€99.99")
                .font(themeProvider.theme.typography.totalPrice)
                .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeProvider.theme.colors.cadaEuroBackground)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
        .themeProvider(.preview)
}
