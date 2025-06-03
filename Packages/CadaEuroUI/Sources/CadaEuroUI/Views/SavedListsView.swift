import SwiftUI
import CadaEuroKit

/// View principal para gestão de listas guardadas
/// Fase 3A: Foundation - Estrutura básica com mock data
public struct SavedListsView: View {
    @Environment(\.themeProvider) private var themeProvider
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SavedListsViewModel()
    
    // MARK: - State Management
    @State private var showingListDetail = false
    @State private var selectedListForDetail: ShoppingList?
    @State private var showingDeleteConfirmation = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.isEmpty {
                    emptyStateView
                } else {
                    listsContentView
                }
            }
            .background(themeProvider.theme.colors.cadaEuroBackground)
            .navigationTitle("Listas Guardadas")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                toolbarContent
            }
            .refreshable {
                await viewModel.refreshLists()
            }
            .sheet(isPresented: $showingListDetail) {
                if let selectedList = selectedListForDetail {
                    SavedListDetailView(shoppingList: selectedList)
                }
            }
            .confirmationDialog(
                "Eliminar Listas",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                deleteConfirmationButtons
            } message: {
                Text(deleteConfirmationMessage)
            }
            .task {
                await viewModel.loadSavedLists()
            }
        }
        .logLifecycle(viewName: "SavedListsView")
    }
    
    // MARK: - Loading View
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: themeProvider.theme.spacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("A carregar listas...")
                .font(themeProvider.theme.typography.bodyMedium)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack {
            Spacer()
            
            EmptyStateView(type: .savedLists)
                .padding(themeProvider.theme.spacing.lg)
            
            Spacer()
        }
    }
    
    // MARK: - Lists Content View
    
    @ViewBuilder
    private var listsContentView: some View {
        ScrollView {
            LazyVStack(spacing: themeProvider.theme.spacing.lg, pinnedViews: [.sectionHeaders]) {
                ForEach(Array(viewModel.groupedLists.keys.sorted(by: sortSections)), id: \.self) { sectionKey in
                    if let listsInSection = viewModel.groupedLists[sectionKey] {
                        Section {
                            listsSectionContent(lists: listsInSection)
                        } header: {
                            sectionHeader(title: sectionKey)
                        }
                    }
                }
            }
            .padding(.horizontal, themeProvider.theme.spacing.lg)
            .padding(.top, themeProvider.theme.spacing.md)
        }
        .overlay(alignment: .bottom) {
            if viewModel.isEditMode && viewModel.hasSelectedLists {
                editModeBottomBar
            }
        }
    }
    
    // MARK: - Section Header
    
    @ViewBuilder
    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(themeProvider.theme.typography.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
            
            Spacer()
        }
        .padding(.horizontal, themeProvider.theme.spacing.lg)
        .padding(.vertical, themeProvider.theme.spacing.sm)
        
    }
    
    // MARK: - Lists Section Content
    
    @ViewBuilder
    private func listsSectionContent(lists: [ShoppingList]) -> some View {
        ForEach(lists.sorted { $0.dateCompleted > $1.dateCompleted }) { list in
            ListCard(
                shoppingList: list,
                onTap: { selectedList in
                    if viewModel.isEditMode {
                        viewModel.toggleSelection(for: selectedList)
                    } else {
                        selectedListForDetail = selectedList
                        showingListDetail = true
                    }
                },
                onRename: { newName in
                    viewModel.renameList(list, to: newName)
                },
                onDelete: {
                    viewModel.deleteList(list)
                }
            )
            .overlay(alignment: .topTrailing) {
                if viewModel.isEditMode {
                    selectionIndicator(for: list)
                }
            }
        }
    }
    
    // MARK: - Selection Indicator
    
    @ViewBuilder
    private func selectionIndicator(for list: ShoppingList) -> some View {
        Image(systemName: viewModel.selectedLists.contains(list.id) ? "checkmark.circle.fill" : "circle")
            .font(.title3)
            .foregroundColor(
                viewModel.selectedLists.contains(list.id) 
                    ? themeProvider.theme.colors.cadaEuroAccent
                    : themeProvider.theme.colors.cadaEuroTextTertiary
            )
            .background(
                Circle()
                    .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
                    .frame(width: 24, height: 24)
            )
            .padding(themeProvider.theme.spacing.sm)
            .onTapGesture {
                viewModel.toggleSelection(for: list)
            }
    }
    
    // MARK: - Edit Mode Bottom Bar
    
    @ViewBuilder
    private var editModeBottomBar: some View {
        HStack(spacing: themeProvider.theme.spacing.lg) {
            Button(action: { showingDeleteConfirmation = true }) {
                HStack(spacing: themeProvider.theme.spacing.xs) {
                    Image(systemName: "trash")
                    Text("Eliminar (\(viewModel.selectedListsCount))")
                }
                .font(themeProvider.theme.typography.bodyMedium)
                .foregroundColor(.white)
                .padding(.horizontal, themeProvider.theme.spacing.lg)
                .padding(.vertical, themeProvider.theme.spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: themeProvider.theme.border.buttonRadius)
                        .fill(.red)
                )
            }
            
            Spacer()
            
            Button("Selecionar Tudo") {
                if viewModel.selectedLists.count == viewModel.savedLists.count {
                    viewModel.clearSelection()
                } else {
                    viewModel.selectAll()
                }
            }
            .font(themeProvider.theme.typography.bodyMedium)
            .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
        }
        .padding(themeProvider.theme.spacing.lg)
        .background(
            Rectangle()
                .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
                .shadow(color: themeProvider.theme.colors.cadaEuroTextTertiary.opacity(0.1), radius: 8, x: 0, y: -2)
        )
    }
    
    // MARK: - Toolbar Content
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Fechar") {
                dismiss()
            }
        }
        
        if !viewModel.isEmpty {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(viewModel.isEditMode ? "Concluído" : "Editar") {
                    viewModel.toggleEditMode()
                }
                .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
            }
        }
        #else
        ToolbarItem(placement: .cancellationAction) {
            Button("Fechar") {
                dismiss()
            }
        }
        
        if !viewModel.isEmpty {
            ToolbarItem(placement: .primaryAction) {
                Button(viewModel.isEditMode ? "Concluído" : "Editar") {
                    viewModel.toggleEditMode()
                }
                .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
            }
        }
        #endif
    }
    
    // MARK: - Delete Confirmation
    
    @ViewBuilder
    private var deleteConfirmationButtons: some View {
        Button("Eliminar", role: .destructive) {
            viewModel.deleteSelectedLists()
        }
        
        Button("Cancelar", role: .cancel) {}
    }
    
    private var deleteConfirmationMessage: String {
        let count = viewModel.selectedListsCount
        if count == 1 {
            return "Esta ação irá eliminar 1 lista guardada."
        } else {
            return "Esta ação irá eliminar \(count) listas guardadas."
        }
    }
    
    // MARK: - Helper Methods
    
    /// Ordena secções por prioridade temporal
    private func sortSections(_ lhs: String, _ rhs: String) -> Bool {
        let priorities = ["Hoje": 0, "Ontem": 1, "Esta semana": 2, "Este mês": 3, "Anteriores": 4]
        let lhsPriority = priorities[lhs] ?? 5
        let rhsPriority = priorities[rhs] ?? 5
        return lhsPriority < rhsPriority
    }
}

// MARK: - Previews

#Preview("Saved Lists - Empty") {
    SavedListsView()
        .themeProvider(.preview)
}

#Preview("Saved Lists - With Data") {
    let view = SavedListsView()
    // Note: O ViewModel carrega dados mock automaticamente
    return view.themeProvider(.preview)
}

#Preview("Saved Lists - Dark Mode") {
    SavedListsView()
        .themeProvider(.darkPreview)
        .preferredColorScheme(.dark)
}
