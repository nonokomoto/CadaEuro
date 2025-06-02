import SwiftUI
import CadaEuroKit

/// Model simplificado para preview (até SwiftData estar implementado)
public struct ShoppingList: Identifiable, Hashable, Sendable {
    public let id = UUID()
    public var name: String
    public let dateCompleted: Date
    public let itemCount: Int
    public let totalAmount: Double
    
    public init(name: String, dateCompleted: Date, itemCount: Int, totalAmount: Double) {
        self.name = name
        self.dateCompleted = dateCompleted
        self.itemCount = itemCount
        self.totalAmount = totalAmount
    }
    
    /// ✅ USAR DateExtensions: Agrupamento temporal para SavedListsView
    public var groupingDescription: String {
        return dateCompleted.groupingDescription
    }
}

/// Estados do ListCard
public enum ListCardState: Sendable {
    case normal
    case editing
    case pressed
}

/// Card premium para exibir listas guardadas
public struct ListCard: View {
    @Environment(\.themeProvider) private var themeProvider
    
    // MARK: - Properties
    private let shoppingList: ShoppingList
    private let onTap: ((ShoppingList) -> Void)?
    private let onRename: ((String) -> Void)?
    private let hasDeleteAction: Bool
    private let onDelete: (() -> Void)?
    
    // MARK: - State
    @State private var cardState: ListCardState = .normal
    @State private var editedName: String = ""
    @State private var showingDeleteConfirmation = false
    @FocusState private var isNameFieldFocused: Bool
    
    public init(
        shoppingList: ShoppingList,
        onTap: ((ShoppingList) -> Void)? = nil,
        onRename: ((String) -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.shoppingList = shoppingList
        self.onTap = onTap
        self.onRename = onRename
        self.hasDeleteAction = onDelete != nil
        self.onDelete = onDelete
        self._editedName = State(initialValue: shoppingList.name)
    }
    
    public var body: some View {
        cardContent
            .background(cardBackground)
            .cornerRadius(themeProvider.theme.border.cardRadius)
            .shadow(
                color: shadowColor,
                radius: cardState == .pressed ? 2 : 6,
                x: 0,
                y: cardState == .pressed ? 1 : 3
            )
            .scaleEffect(cardState == .pressed ? 0.98 : 1.0)
            .animation(themeProvider.theme.animation.quick, value: cardState)
            .contextMenu {
                contextMenuContent
            }
            .confirmationDialog(
                "Eliminar Lista",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                deleteConfirmationButtons
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityHint("Toque para editar nome, prima e mantenha para mais opções")
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: themeProvider.theme.spacing.lg) {
            // Header: Nome e total (em paralelo)
            HStack {
                nameSection
                Spacer()
                totalSection
            }
            
            // Footer: Contagem de itens e data (lado a lado)
            HStack(spacing: themeProvider.theme.spacing.lg) {
                itemsCountSection
                dateSection
                Spacer()
            }
        }
        .padding(themeProvider.theme.spacing.lg)
        .contentShape(Rectangle()) // Para gestos em toda a área
        .onTapGesture {
            handleTap()
        }
        .onLongPressGesture(minimumDuration: 0) { pressing in
            withAnimation(themeProvider.theme.animation.quick) {
                cardState = pressing ? .pressed : .normal
            }
        } perform: {}
    }
    
    @ViewBuilder
    private var nameSection: some View {
        if cardState == .editing {
            HStack(spacing: themeProvider.theme.spacing.sm) {
                TextField("Nome da lista", text: $editedName)
                    .font(themeProvider.theme.typography.titleMedium)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                    .focused($isNameFieldFocused)
                    .onSubmit {
                        confirmEdit()
                    }
                
                // Botões de confirmação/cancelamento
                HStack(spacing: themeProvider.theme.spacing.xs) {
                    Button(action: confirmEdit) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                    }
                    
                    Button(action: cancelEdit) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.title3)
                    }
                }
            }
        } else {
            Text(shoppingList.name.isEmpty ? "Lista de compras" : shoppingList.name)
                .font(themeProvider.theme.typography.titleMedium)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                .lineLimit(2)
        }
    }
    
    @ViewBuilder
    private var dateSection: some View {
        HStack(spacing: themeProvider.theme.spacing.xs) {
            Image(systemName: "calendar")
                .font(.caption)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextTertiary)
            
            Text(formattedDate)
                .font(themeProvider.theme.typography.bodySmall)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
        }
    }
    
    @ViewBuilder
    private var itemsCountSection: some View {
        HStack(spacing: themeProvider.theme.spacing.xs) {
            Image(systemName: "list.bullet")
                .font(.caption)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextTertiary)
            
            Text(itemsCountText)
                .font(themeProvider.theme.typography.bodySmall)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
        }
    }
    
    @ViewBuilder
    private var totalSection: some View {
        Text(formattedTotal)
            .font(themeProvider.theme.typography.titleMedium)
            .fontWeight(.semibold)
            .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
    }
    
    @ViewBuilder
    private var contextMenuContent: some View {
        Button(action: startEditing) {
            Label("Renomear", systemImage: "pencil")
        }
        
        if hasDeleteAction {
            Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                Label("Eliminar", systemImage: "trash")
            }
        }
    }
    
    @ViewBuilder
    private var deleteConfirmationButtons: some View {
        Button("Eliminar", role: .destructive) {
            onDelete?()
        }
        
        Button("Cancelar", role: .cancel) {}
    }
    
    // MARK: - Computed Properties
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: themeProvider.theme.border.cardRadius)
            .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
            .overlay(
                RoundedRectangle(cornerRadius: themeProvider.theme.border.cardRadius)
                    .stroke(
                        themeProvider.theme.colors.cadaEuroSeparator,
                        lineWidth: 0.5
                    )
            )
    }
    
    private var shadowColor: Color {
        themeProvider.theme.colors.cadaEuroTextTertiary.opacity(0.15)
    }
    
    private var formattedDate: String {
        // ✅ USAR DateExtensions: Formatação específica para SavedListsView
        return shoppingList.dateCompleted.asSavedListDate
    }
    
    private var itemsCountText: String {
        let count = shoppingList.itemCount
        return count == 1 ? "1 item" : "\(count) itens"
    }
    
    private var formattedTotal: String {
        String(format: "€%.2f", shoppingList.totalAmount)
    }
    
    private var accessibilityLabel: String {
        let name = shoppingList.name.isEmpty ? "Lista de compras" : shoppingList.name
        // ✅ USAR DateExtensions: Data acessível para VoiceOver
        let accessibleDate = shoppingList.dateCompleted.asAccessibleDate
        return "\(name), concluída \(accessibleDate), \(itemsCountText), total \(formattedTotal)"
    }
    
    // MARK: - Actions
    
    private func handleTap() {
        guard cardState != .editing else { return }
        
        if let onTap = onTap {
            onTap(shoppingList)
        } else {
            startEditing()
        }
    }
    
    private func startEditing() {
        withAnimation(themeProvider.theme.animation.spring) {
            cardState = .editing
            editedName = shoppingList.name
        }
        
        // Focar o campo após a animação
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isNameFieldFocused = true
        }
    }
    
    private func confirmEdit() {
        let finalName = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        withAnimation(themeProvider.theme.animation.spring) {
            cardState = .normal
            isNameFieldFocused = false
        }
        
        onRename?(finalName.isEmpty ? "Lista de compras" : finalName)
    }
    
    private func cancelEdit() {
        withAnimation(themeProvider.theme.animation.spring) {
            cardState = .normal
            editedName = shoppingList.name
            isNameFieldFocused = false
        }
    }
}

// MARK: - Sample Data
extension ShoppingList {
    static let sampleLists: [ShoppingList] = [
        ShoppingList(
            name: "Compras do Pingo Doce",
            dateCompleted: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            itemCount: 8,
            totalAmount: 45.67
        ),
        ShoppingList(
            name: "Lista de compras",
            dateCompleted: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            itemCount: 12,
            totalAmount: 89.12
        ),
        ShoppingList(
            name: "Continente - Compras Semanais",
            dateCompleted: Calendar.current.date(byAdding: .weekday, value: -1, to: Date()) ?? Date(),
            itemCount: 23,
            totalAmount: 156.89
        )
    ]
}

#Preview("List Cards") {
    VStack(spacing: 16) {
        ForEach(ShoppingList.sampleLists) { list in
            ListCard(
                shoppingList: list,
                onTap: { list in
                    print("Tapped: \(list.name)")
                },
                onRename: { newName in
                    print("Renamed to: \(newName)")
                },
                onDelete: {
                    print("Deleted: \(list.name)")
                }
            )
        }
    }
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("List Card Dark") {
    VStack(spacing: 16) {
        ListCard(
            shoppingList: ShoppingList.sampleLists[0],
            onRename: { print("Renamed: \($0)") },
            onDelete: { print("Deleted") }
        )
        
        ListCard(
            shoppingList: ShoppingList.sampleLists[1]
        )
    }
    .padding()
    .background(ThemeProvider.darkPreview.theme.colors.cadaEuroBackground)
    .themeProvider(.darkPreview)
    .preferredColorScheme(.dark)
}

// MARK: - Collection Extensions for Temporal Organization

/// Extensões para coleções de ShoppingList com funcionalidades temporais
public extension Collection where Element == ShoppingList {
    
    /// ✅ USAR DateExtensions: Ordena listas por data (mais recente primeiro)
    /// - Use Case: Lista principal ordenada por relevância
    /// - Returns: Array ordenado cronologicamente
    var sortedByDate: [ShoppingList] {
        return self.sorted { $0.dateCompleted > $1.dateCompleted }
    }
    
    /// ✅ USAR DateExtensions: Filtra listas do período atual
    /// - Use Case: Destaque para listas recentes
    /// - Returns: Array com listas de hoje, ontem e esta semana
    var recentLists: [ShoppingList] {
        return self.filter { $0.dateCompleted.isThisWeek || $0.dateCompleted.isToday || $0.dateCompleted.isYesterday }
    }
    
    /// ✅ USAR DateExtensions: Filtra listas do mês atual
    /// - Use Case: Filtro mensal em SavedListsView
    /// - Returns: Array com listas do mês corrente
    var fromThisMonth: [ShoppingList] {
        return self.filter { $0.dateCompleted.isThisMonth }
    }
    
    /// ✅ USAR DateExtensions: Encontra lista mais recente
    /// - Use Case: "Última lista completada"
    /// - Returns: ShoppingList? com data mais recente
    var mostRecent: ShoppingList? {
        return self.max { $0.dateCompleted < $1.dateCompleted }
    }
    
    /// ✅ USAR DateExtensions: Agrupa listas por período temporal
    /// - Use Case: Organizar SavedListsView por "Hoje", "Esta semana", etc.
    /// - Returns: Dictionary agrupado por descrição temporal
    func groupedByPeriod() -> [String: [ShoppingList]] {
        return Dictionary(grouping: self) { list in
            list.groupingDescription
        }
    }
}

#Preview("List Card Editing") {
    @Previewable @State var cardState: ListCardState = .editing
    
    return ListCard(
        shoppingList: ShoppingList.sampleLists[0],
        onRename: { print("Renamed: \($0)") }
    )
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}
