import SwiftUI
import CadaEuroKit

/// View para exibir detalhes de uma lista guardada
public struct SavedListDetailView: View {
    @Environment(\.themeProvider) private var themeProvider
    @Environment(\.dismiss) private var dismiss
    
    private let shoppingList: ShoppingList
    
    public init(shoppingList: ShoppingList) {
        self.shoppingList = shoppingList
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: themeProvider.theme.spacing.xl) {
                    // Header com informações principais
                    headerSection
                    
                    // Resumo da lista
                    summarySection
                    
                    // Placeholder para itens da lista
                    itemsSection
                    
                    Spacer(minLength: themeProvider.theme.spacing.xl)
                }
                .padding(themeProvider.theme.spacing.lg)
            }
            .background(themeProvider.theme.colors.cadaEuroBackground)
            .navigationTitle(shoppingList.name.isEmpty ? "Lista de compras" : shoppingList.name)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { exportList() }) {
                            Label("Exportar", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: { duplicateList() }) {
                            Label("Duplicar", systemImage: "doc.on.doc")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: { deleteList() }) {
                            Label("Eliminar", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
                    }
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: { exportList() }) {
                            Label("Exportar", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: { duplicateList() }) {
                            Label("Duplicar", systemImage: "doc.on.doc")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: { deleteList() }) {
                            Label("Eliminar", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
                    }
                }
                #endif
            }
        }
        .logLifecycle(viewName: "SavedListDetailView")
    }
    
    // MARK: - Sections
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: themeProvider.theme.spacing.md) {
            // Data de conclusão
            HStack(spacing: themeProvider.theme.spacing.xs) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextTertiary)
                
                Text("Concluída em \(shoppingList.dateCompleted.asSavedListDate)")
                    .font(themeProvider.theme.typography.bodySmall)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
            }
            
            // Total em destaque
            HStack {
                Text("Total:")
                    .font(themeProvider.theme.typography.titleMedium)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                
                Spacer()
                
                Text(String(format: "€%.2f", shoppingList.totalAmount))
                    .font(themeProvider.theme.typography.titleLarge)
                    .fontWeight(.bold)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
            }
        }
        .padding(themeProvider.theme.spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: themeProvider.theme.border.cardRadius)
                .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: themeProvider.theme.border.cardRadius)
                        .stroke(themeProvider.theme.colors.cadaEuroSeparator, lineWidth: 0.5)
                )
        )
    }
    
    @ViewBuilder
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: themeProvider.theme.spacing.md) {
            Text("Resumo")
                .font(themeProvider.theme.typography.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
            
            HStack(spacing: themeProvider.theme.spacing.xl) {
                // Número de itens
                VStack(alignment: .leading, spacing: themeProvider.theme.spacing.xs) {
                    Text("\(shoppingList.itemCount)")
                        .font(themeProvider.theme.typography.titleLarge)
                        .fontWeight(.bold)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
                    
                    Text(shoppingList.itemCount == 1 ? "Item" : "Itens")
                        .font(themeProvider.theme.typography.bodySmall)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                }
                
                Spacer()
                
                // Preço médio por item
                VStack(alignment: .trailing, spacing: themeProvider.theme.spacing.xs) {
                    Text(String(format: "€%.2f", shoppingList.totalAmount / Double(max(shoppingList.itemCount, 1))))
                        .font(themeProvider.theme.typography.titleLarge)
                        .fontWeight(.bold)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
                    
                    Text("Preço médio")
                        .font(themeProvider.theme.typography.bodySmall)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                }
            }
        }
        .padding(themeProvider.theme.spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: themeProvider.theme.border.cardRadius)
                .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: themeProvider.theme.border.cardRadius)
                        .stroke(themeProvider.theme.colors.cadaEuroSeparator, lineWidth: 0.5)
                )
        )
    }
    
    @ViewBuilder
    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: themeProvider.theme.spacing.md) {
            Text("Itens da Lista")
                .font(themeProvider.theme.typography.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
            
            // TODO: Fase 5 - Implementar lista real de itens
            itemsListView
        }
        .padding(themeProvider.theme.spacing.lg)
        .background(itemsBackgroundView)
    }
    
    @ViewBuilder
    private var itemsListView: some View {
        VStack(spacing: themeProvider.theme.spacing.md) {
            ForEach(0..<min(shoppingList.itemCount, 5), id: \.self) { index in
                itemRowView(for: index)
            }
            
            if shoppingList.itemCount > 5 {
                moreItemsView
            }
        }
    }
    
    @ViewBuilder
    private func itemRowView(for index: Int) -> some View {
        HStack {
            Image(systemName: "circle.fill")
                .font(.caption)
                .foregroundColor(themeProvider.theme.colors.cadaEuroAccent.opacity(0.6))
            
            Text("Item \(index + 1)")
                .font(themeProvider.theme.typography.bodyMedium)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
            
            Spacer()
            
            Text("€--,--")
                .font(themeProvider.theme.typography.bodySmall)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
        }
        .padding(.horizontal, themeProvider.theme.spacing.md)
        .padding(.vertical, themeProvider.theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: themeProvider.theme.border.inputRadius)
                .fill(themeProvider.theme.colors.cadaEuroBackground)
        )
    }
    
    @ViewBuilder
    private var moreItemsView: some View {
        HStack {
            Image(systemName: "ellipsis")
                .font(.caption)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextTertiary)
            
            Text("e mais \(shoppingList.itemCount - 5) itens")
                .font(themeProvider.theme.typography.bodySmall)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextTertiary)
            
            Spacer()
        }
        .padding(.horizontal, themeProvider.theme.spacing.md)
        .padding(.vertical, themeProvider.theme.spacing.sm)
    }
    
    @ViewBuilder
    private var itemsBackgroundView: some View {
        RoundedRectangle(cornerRadius: themeProvider.theme.border.cardRadius)
            .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
            .overlay(
                RoundedRectangle(cornerRadius: themeProvider.theme.border.cardRadius)
                    .stroke(themeProvider.theme.colors.cadaEuroSeparator, lineWidth: 0.5)
            )
    }
    
    // MARK: - Actions
    
    private func exportList() {
        CadaEuroLogger.info("Exporting saved list", metadata: [
            "list_id": shoppingList.id.uuidString,
            "list_name": shoppingList.name
        ], category: .userInteraction)
        
        // TODO: Fase 5 - Implementar exportação real
        // Pode ser PDF, texto, CSV, etc.
    }
    
    private func duplicateList() {
        CadaEuroLogger.info("Duplicating saved list", metadata: [
            "list_id": shoppingList.id.uuidString,
            "list_name": shoppingList.name
        ], category: .userInteraction)
        
        // TODO: Fase 5 - Implementar duplicação real
        // Criar nova lista com mesmo conteúdo
    }
    
    private func deleteList() {
        CadaEuroLogger.info("Deleting saved list from detail view", metadata: [
            "list_id": shoppingList.id.uuidString,
            "list_name": shoppingList.name
        ], category: .userInteraction)
        
        // TODO: Fase 5 - Implementar eliminação real
        // Eliminar lista e fechar modal
        dismiss()
    }
}

// MARK: - Previews

#Preview("Saved List Detail") {
    SavedListDetailView(shoppingList: ShoppingList.sampleLists[0])
        .themeProvider(.preview)
}

#Preview("Saved List Detail - Dark") {
    SavedListDetailView(shoppingList: ShoppingList.sampleLists[1])
        .themeProvider(.darkPreview)
        .preferredColorScheme(.dark)
}
