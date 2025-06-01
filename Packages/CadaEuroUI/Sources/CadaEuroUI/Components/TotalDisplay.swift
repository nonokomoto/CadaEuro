import SwiftUI
import CadaEuroKit

/// Estados do TotalDisplay
public enum TotalDisplayState: Sendable, Equatable {
    case normal         // Estado padrão
    case empty          // Lista vazia (€0,00)
    case large          // Valor alto (destaque especial)
    case loading        // Carregando cálculos
}

/// Display premium para o total da lista de compras
///
/// Componente central da aplicação que mostra o valor total em destaque,
/// com background transparente para usar o background do parent.
/// O valor total mantém sempre cor azul (accent) independente do estado.
public struct TotalDisplay: View {
    @Environment(\.themeProvider) private var themeProvider
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Properties
    private let amount: Double
    private let state: TotalDisplayState
    private let onSaveList: (() -> Void)?
    private let onNewList: (() -> Void)?
    
    // MARK: - State
    @State private var isPressed = false
    @State private var showingMenu = false
    @State private var showingConfirmNewList = false
    
    public init(
        amount: Double,
        state: TotalDisplayState = .normal,
        onSaveList: (() -> Void)? = nil,
        onNewList: (() -> Void)? = nil
    ) {
        self.amount = amount
        self.state = state
        self.onSaveList = onSaveList
        self.onNewList = onNewList
    }
    
    public var body: some View {
        VStack(spacing: themeProvider.theme.spacing.sm) {
            // Label superior
            totalLabel
            
            // Valor principal
            totalValue
                .contentShape(Rectangle())
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .onTapGesture { }
                .onLongPressGesture(minimumDuration: 0) { pressing in
                    withAnimation(themeProvider.theme.animation.quick) {
                        isPressed = pressing
                    }
                    
                    // ✅ TODO: SensoryFeedback quando disponível
                    // .sensoryFeedback(.impact(.medium), trigger: showingMenu)
                } perform: {
                    if onSaveList != nil || onNewList != nil {
                        showingMenu = true
                    }
                }
                .confirmationDialog(
                    "Opções da Lista",
                    isPresented: $showingMenu,
                    titleVisibility: .visible
                ) {
                    menuActions
                }
                .alert(
                    "Nova Lista",
                    isPresented: $showingConfirmNewList
                ) {
                    newListConfirmation
                } message: {
                    Text("A lista atual será guardada automaticamente. Pretende criar uma nova lista?")
                }
        }
        .padding(themeProvider.theme.spacing.lg)
        // ✅ SEM BACKGROUND - usa background do parent
        .animation(themeProvider.theme.animation.spring, value: amount)
        .animation(themeProvider.theme.animation.spring, value: state)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(.updatesFrequently)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var totalLabel: some View {
        Text("Total")
            .font(themeProvider.theme.typography.bodyMedium)
            .foregroundColor(labelColor)
            .accessibilityHidden(true)
    }
    
    @ViewBuilder
    private var totalValue: some View {
        Text(formattedAmount)
            .font(themeProvider.theme.typography.totalPrice)
            .foregroundColor(valueColor) // ✅ SEMPRE AZUL (accent)
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            // ✅ Glow effect apenas em dark mode, sem background próprio
            .shadow(
                color: glowColor,
                radius: glowRadius,
                x: 0,
                y: 0
            )
    }
    
    @ViewBuilder
    private var menuActions: some View {
        if let onSaveList = onSaveList {
            Button("Guardar Lista") {
                onSaveList()
            } 

        }
        
        if let onNewList = onNewList {
            Button("Nova Lista") {
                if amount > 0 {
                    showingConfirmNewList = true
                } else {
                    onNewList()
                }
            }
        }
        
        Button("Cancelar", role: .cancel) { }
    }
    
    @ViewBuilder
    private var newListConfirmation: some View {
        Button("Criar Nova Lista") {
            onNewList?()
        }
        
        Button("Cancelar", role: .cancel) { }
    }
    
    // MARK: - Computed Properties
    
    private var formattedAmount: String {
        // ✅ USAR DoubleExtensions: Formatação específica para TotalDisplay
        return amount.asTotalDisplayPrice
    }
    
    private var labelColor: Color {
        switch state {
        case .loading:
            return themeProvider.theme.colors.cadaEuroTextTertiary
        default:
            return themeProvider.theme.colors.cadaEuroTextSecondary
        }
    }
    
    private var valueColor: Color {
        // ✅ SEMPRE AZUL (accent) - Nunca muda independente do estado
        return themeProvider.theme.colors.cadaEuroAccent
    }
    
    // ✅ Glow effect apenas em dark mode sem background próprio
    private var glowColor: Color {
        if colorScheme == .dark && state != .empty {
            return themeProvider.theme.colors.cadaEuroAccent.opacity(0.3)
        } else {
            return .clear
        }
    }
    
    private var glowRadius: CGFloat {
        if colorScheme == .dark && state != .empty {
            return 20
        } else {
            return 0
        }
    }
    
    private var accessibilityLabel: String {
        switch state {
        case .loading:
            return "Total da lista: calculando"
        case .empty:
            return "Total da lista: \(amount.asCurrencyAccessible)"
        default:
            return "Total da lista: \(amount.asCurrencyAccessible)"
        }
    }
    
    private var accessibilityHint: String {
        if onSaveList != nil || onNewList != nil {
            return "Prima e mantenha premido para opções da lista"
        } else {
            return "Total atual da sua lista de compras"
        }
    }
}

// MARK: - State Helpers

public extension TotalDisplay {
    
    /// Determina estado baseado no valor
    ///
    /// - Parameter amount: Valor a analisar
    /// - Returns: TotalDisplayState apropriado
    static func stateFor(amount: Double) -> TotalDisplayState {
        if amount == 0.0 {
            return .empty
        } else if amount > 500.0 {
            return .large
        } else {
            return .normal
        }
    }
    
    /// TotalDisplay com estado automático baseado no valor
    ///
    /// - Parameters:
    ///   - amount: Valor total
    ///   - onSaveList: Callback para guardar lista
    ///   - onNewList: Callback para nova lista
    /// - Returns: TotalDisplay configurado
    static func automatic(
        amount: Double,
        onSaveList: (() -> Void)? = nil,
        onNewList: (() -> Void)? = nil
    ) -> TotalDisplay {
        return TotalDisplay(
            amount: amount,
            state: stateFor(amount: amount),
            onSaveList: onSaveList,
            onNewList: onNewList
        )
    }
}

// MARK: - Previews

#Preview("Total Normal") {
    VStack(spacing: 32) {
        TotalDisplay(amount: 45.67, state: .normal)
        
        TotalDisplay.automatic(
            amount: 123.45,
            onSaveList: { print("Save list") },
            onNewList: { print("New list") }
        )
    }
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("Total States") {
    VStack(spacing: 24) {
        TotalDisplay(amount: 0.0, state: .empty)
        TotalDisplay(amount: 45.67, state: .normal)
        TotalDisplay(amount: 567.89, state: .large)
        TotalDisplay(amount: 12.34, state: .loading)
    }
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("Total Dark Mode") {
    VStack(spacing: 24) {
        TotalDisplay(amount: 45.67, state: .normal)
        TotalDisplay(amount: 567.89, state: .large)
    }
    .padding()
    .background(ThemeProvider.darkPreview.theme.colors.cadaEuroBackground)
    .themeProvider(.darkPreview)
    .preferredColorScheme(.dark)
}

#Preview("Total Empty State") {
    TotalDisplay(amount: 0.0, state: .empty)
        .padding()
        .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
        .themeProvider(.preview)
}

#Preview("Total with Actions") {
    TotalDisplay(
        amount: 89.43,
        state: .normal,
        onSaveList: { print("Saving list...") },
        onNewList: { print("Creating new list...") }
    )
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("Total Loading") {
    TotalDisplay(amount: 23.45, state: .loading)
        .padding()
        .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
        .themeProvider(.preview)
}
