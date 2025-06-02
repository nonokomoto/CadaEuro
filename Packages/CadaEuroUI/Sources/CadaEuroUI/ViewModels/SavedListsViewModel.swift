import SwiftUI
import CadaEuroKit

/// ViewModel para SavedListsView com gestão de mock data
@MainActor
public final class SavedListsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var savedLists: [ShoppingList] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var isEditMode = false
    @Published public var selectedLists: Set<UUID> = []
    
    // MARK: - Computed Properties
    
    public var isEmpty: Bool {
        savedLists.isEmpty
    }
    
    public var groupedLists: [String: [ShoppingList]] {
        savedLists.groupedByPeriod()
    }
    
    public var hasSelectedLists: Bool {
        !selectedLists.isEmpty
    }
    
    public var selectedListsCount: Int {
        selectedLists.count
    }
    
    // MARK: - Initialization
    
    public init() {
        loadMockData()
    }
    
    // MARK: - Data Loading
    
    public func loadSavedLists() async {
        CadaEuroLogger.info("Loading saved lists", category: .userInteraction)
        
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Fase 5 - Implementar SwiftData
            // savedLists = try await persistenceManager.fetchAllLists()
            
            // Mock para agora
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
            loadMockData()
            
            CadaEuroLogger.info("Loaded \(savedLists.count) saved lists", category: .userInteraction)
            
        } catch {
            CadaEuroLogger.error("Failed to load saved lists", error: error, category: .error)
            errorMessage = "Erro ao carregar listas guardadas"
        }
        
        isLoading = false
    }
    
    public func refreshLists() async {
        await loadSavedLists()
    }
    
    // MARK: - List Management
    
    public func deleteList(_ list: ShoppingList) {
        CadaEuroLogger.info("Deleting saved list", metadata: [
            "list_id": list.id.uuidString,
            "list_name": list.name
        ], category: .userInteraction)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            savedLists.removeAll { $0.id == list.id }
            selectedLists.remove(list.id)
        }
        
        // TODO: Fase 5 - Remover do SwiftData
        // await persistenceManager.delete(list)
    }
    
    public func deleteSelectedLists() {
        CadaEuroLogger.info("Deleting selected lists", metadata: [
            "count": String(selectedLists.count)
        ], category: .userInteraction)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            savedLists.removeAll { selectedLists.contains($0.id) }
            selectedLists.removeAll()
        }
        
        // TODO: Fase 5 - Remover múltiplas do SwiftData
        // await persistenceManager.deleteMultiple(selectedLists)
    }
    
    public func renameList(_ list: ShoppingList, to newName: String) {
        CadaEuroLogger.info("Renaming saved list", metadata: [
            "list_id": list.id.uuidString,
            "old_name": list.name,
            "new_name": newName
        ], category: .userInteraction)
        
        if let index = savedLists.firstIndex(where: { $0.id == list.id }) {
            savedLists[index].name = newName
        }
        
        // TODO: Fase 5 - Atualizar no SwiftData
        // await persistenceManager.update(list)
    }
    
    // MARK: - Selection Management
    
    public func toggleSelection(for list: ShoppingList) {
        if selectedLists.contains(list.id) {
            selectedLists.remove(list.id)
        } else {
            selectedLists.insert(list.id)
        }
    }
    
    public func selectAll() {
        selectedLists = Set(savedLists.map { $0.id })
    }
    
    public func clearSelection() {
        selectedLists.removeAll()
    }
    
    public func toggleEditMode() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isEditMode.toggle()
            if !isEditMode {
                clearSelection()
            }
        }
    }
    
    // MARK: - Mock Data
    
    private func loadMockData() {
        savedLists = ShoppingList.sampleLists
    }
    
    // MARK: - Error Handling
    
    public func handleError(_ error: Error) {
        CadaEuroLogger.error("SavedListsViewModel error occurred", error: error, category: .error)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            errorMessage = error.localizedDescription
        }
        
        // Clear error after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.errorMessage = nil
            }
        }
    }
}
