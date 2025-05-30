import SwiftUI
import CadaEuroKit

/// Estado de edição do cartão de lista
public enum ListCardEditState {
    case viewing
    case editing
}

/// Componente que exibe um cartão de lista guardada
/// Permite visualizar o nome da lista, data, total e número de itens
public struct ListCard: View {
    @Environment(\.themeProvider) private var themeProvider
    
    /// Nome da lista
    @Binding private var name: String
    
    /// Nome temporário durante edição
    @State private var editingName: String = ""
    
    /// Data de conclusão da lista
    private let completionDate: Date
    
    /// Número total de itens na lista
    private let itemCount: Int
    
    /// Valor total da lista em euros
    private let totalValue: Double
    
    /// Estado de edição atual
    @State private var editState: ListCardEditState = .viewing
    
    /// Ação executada ao tocar no cartão
    private let onTap: () -> Void
    
    /// Ação executada ao renomear a lista
    private let onRename: (String) -> Void
    
    /// Ação executada ao apagar a lista
    private let onDelete: () -> Void
    
    /// Estado de animação
    @State private var isPressed: Bool = false
    
    /// Formata a data no formato "d MMM"
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "pt_PT")
        return formatter.string(from: completionDate)
    }
    
    /// Formata o valor total
    private var formattedTotal: String {
        return String(format: "€%.2f", totalValue)
    }
    
    /// Inicializador do componente
    /// - Parameters:
    ///   - name: Nome da lista (binding para permitir edição)
    ///   - completionDate: Data de conclusão da lista
    ///   - itemCount: Número total de itens na lista
    ///   - totalValue: Valor total da lista em euros
    ///   - onTap: Ação executada ao tocar no cartão
    ///   - onRename: Ação executada ao renomear a lista
    ///   - onDelete: Ação executada ao apagar a lista
    public init(
        name: Binding<String>,
        completionDate: Date,
        itemCount: Int,
        totalValue: Double,
        onTap: @escaping () -> Void,
        onRename: @escaping (String) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self._name = name
        self.completionDate = completionDate
        self.itemCount = itemCount
        self.totalValue = totalValue
        self.onTap = onTap
        self.onRename = onRename
        self.onDelete = onDelete
        self._editingName = State(initialValue: name.wrappedValue)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Conteúdo do cartão
            cardContent
                .contentShape(Rectangle())
                .contextMenu {
                    contextMenuContent
                }
        }
        .background(themeProvider.theme.colors.cadaEuroComponentBackground)
        .cornerRadius(themeProvider.theme.border.cardRadius)
        .shadow(
            color: Color.black.opacity(0.1),
            radius: themeProvider.theme.border.shadowRadius1,
            x: 0,
            y: themeProvider.theme.border.shadowYOffset1
        )
        .scaleEffect(isPressed ? themeProvider.theme.animation.pressedScale : 1.0)
        .animation(themeProvider.theme.animation.standard, value: isPressed)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Lista \(name), \(formattedDate), \(itemCount) itens, total \(formattedTotal)")
        .accessibilityHint("Toque para ver detalhes. Pressione e mantenha premido para opções.")
    }
    
    /// Conteúdo do cartão
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: themeProvider.theme.spacing.sm) {
            // Cabeçalho com nome e data
            HStack {
                if editState == .editing {
                    editNameView
                } else {
                    Text(name)
                        .font(themeProvider.theme.typography.titleMedium)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text(formattedDate)
                    .font(themeProvider.theme.typography.caption)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
            }
            
            // Separador
            Divider()
                .background(themeProvider.theme.colors.cadaEuroTextTertiary.opacity(0.3))
                .padding(.vertical, themeProvider.theme.spacing.xs / 2)
            
            // Informações de itens e total
            HStack {
                // Número de itens
                HStack(spacing: themeProvider.theme.spacing.xs) {
                    Image(systemName: "cart")
                        .font(themeProvider.theme.typography.caption)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                    
                    Text("\(itemCount) itens")
                        .font(themeProvider.theme.typography.caption)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                }
                
                Spacer()
                
                // Valor total
                Text(formattedTotal)
                    .font(themeProvider.theme.typography.bodyLarge)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
            }
        }
        .padding(themeProvider.theme.spacing.xl)
        .onTapGesture {
            if editState == .viewing {
                hapticFeedback(.light)
                withAnimation {
                    isPressed = true
                }
                
                // Reseta a animação após um breve período
                DispatchQueue.main.asyncAfter(deadline: .now() + themeProvider.theme.animation.shortDuration) {
                    withAnimation {
                        isPressed = false
                    }
                    onTap()
                }
            }
        }
        .onLongPressGesture {
            if editState == .viewing {
                hapticFeedback(.medium)
            }
        }
    }
    
    /// View para edição do nome
    private var editNameView: some View {
        HStack(spacing: themeProvider.theme.spacing.xs) {
            TextField("Nome da lista", text: $editingName)
                .font(themeProvider.theme.typography.titleMedium)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                .submitLabel(.done)
                .onSubmit(confirmRename)
            
            // Botões de confirmação e cancelamento
            HStack(spacing: themeProvider.theme.spacing.xs) {
                Button(action: confirmRename) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(themeProvider.theme.colors.cadaEuroSuccess)
                        .font(themeProvider.theme.typography.bodyLarge)
                }
                
                Button(action: cancelRename) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(themeProvider.theme.colors.cadaEuroError)
                        .font(themeProvider.theme.typography.bodyLarge)
                }
            }
        }
    }
    
    /// Conteúdo do menu contextual
    private var contextMenuContent: some View {
        Group {
            Button(action: startRenaming) {
                Label("Renomear", systemImage: "pencil")
            }
            
            Button(role: .destructive, action: confirmDelete) {
                Label("Apagar", systemImage: "trash")
            }
        }
    }
    
    /// Inicia o processo de renomeação
    private func startRenaming() {
        editingName = name
        withAnimation {
            editState = .editing
        }
    }
    
    /// Confirma a renomeação
    private func confirmRename() {
        // Validação: nome vazio torna-se "Lista de compras"
        let newName = editingName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 
            "Lista de compras" : editingName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        onRename(newName)
        
        withAnimation {
            editState = .viewing
        }
        
        hapticFeedback(.success)
    }
    
    /// Cancela a renomeação
    private func cancelRename() {
        editingName = name
        
        withAnimation {
            editState = .viewing
        }
        
        hapticFeedback(.light)
    }
    
    /// Confirma a exclusão com alerta
    private func confirmDelete() {
        // Na implementação real, aqui seria mostrado um alerta de confirmação
        // Para este componente, apenas chamamos a ação diretamente
        onDelete()
        hapticFeedback(.heavy)
    }
    
    /// Fornece feedback háptico utilizando o HapticManager centralizado
    private func hapticFeedback(_ type: HapticManager.FeedbackType) {
        HapticManager.shared.feedback(type)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var listName = "Compras Semanais"
        
        var body: some View {
            VStack(spacing: 20) {
                ListCard(
                    name: $listName,
                    completionDate: Date(),
                    itemCount: 12,
                    totalValue: 45.67,
                    onTap: {},
                    onRename: { newName in
                        listName = newName
                    },
                    onDelete: {}
                )
                
                ListCard(
                    name: $listName,
                    completionDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                    itemCount: 5,
                    totalValue: 23.45,
                    onTap: {},
                    onRename: { newName in
                        listName = newName
                    },
                    onDelete: {}
                )
            }
            .padding()
            .background(themeProvider.theme.colors.cadaEuroBackground)
            .withThemeProvider(ThemeProvider())
        }
    }
    
    return PreviewWrapper()
}
