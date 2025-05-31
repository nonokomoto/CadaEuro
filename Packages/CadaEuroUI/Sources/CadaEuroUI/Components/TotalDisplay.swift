import SwiftUI

/// Estados do display de total
public enum TotalDisplayState: Sendable {
    case empty      // €0.00
    case normal     // Valor padrão
    case large      // Valores acima de €1000
    case loading    // Durante cálculos
    
    public var isInteractive: Bool {
        switch self {
        case .loading: return false
        default: return true
        }
    }
}

/// Display premium do total com efeitos visuais e menu contextual
public struct TotalDisplay: View {
    @Environment(\.themeProvider) private var themeProvider
    @Environment(\.colorScheme) private var colorScheme
    
    private let total: Double
    private let onSaveList: () -> Void
    private let onNewList: () -> Void
    private let isLoading: Bool
    
    @State private var isPressed = false
    @State private var showingMenu = false
    @State private var animateValue = false
    
    // MARK: - Initializers
    
    public init(
        total: Double,
        isLoading: Bool = false,
        onSaveList: @escaping () -> Void,
        onNewList: @escaping () -> Void
    ) {
        self.total = total
        self.isLoading = isLoading
        self.onSaveList = onSaveList
        self.onNewList = onNewList
    }
    
    public var body: some View {
        VStack(spacing: themeProvider.theme.spacing.sm) {
            // Label "Total"
            Text("Total")
                .font(themeProvider.theme.typography.bodyMedium)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                .animation(themeProvider.theme.animation.spring, value: totalState)
            
            // Valor principal com animação
            Group {
                if isLoading {
                    loadingView
                } else {
                    totalValueView
                }
            }
        }
        .padding(themeProvider.theme.spacing.lg)
        // ✅ Background removido - usa background do parent
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(themeProvider.theme.animation.quick, value: isPressed)
        // Long press gesture para menu
        .onLongPressGesture(minimumDuration: 0.5) {
            if totalState.isInteractive {
                showingMenu = true
            }
        }
        .onLongPressGesture(minimumDuration: 0) { pressing in
            if totalState.isInteractive {
                isPressed = pressing
            }
        } perform: {}
        // Menu contextual
        .confirmationDialog("Opções da lista", isPresented: $showingMenu) {
            menuActions
        } message: {
            Text("Escolha uma ação para a lista atual")
        }
        // Acessibilidade
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(totalState.isInteractive ? [.isButton] : [])
        // Animação quando valor muda
        .onChange(of: total) { _, _ in
            withAnimation(themeProvider.theme.animation.spring) {
                animateValue.toggle()
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var totalValueView: some View {
        Text(formattedTotal)
            .font(themeProvider.theme.typography.totalPrice)
            .foregroundColor(totalColor)
            .multilineTextAlignment(.center)
            .scaleEffect(animateValue ? 1.05 : 1.0)
            .animation(themeProvider.theme.animation.spring, value: animateValue)
            .animation(themeProvider.theme.animation.spring, value: total)
    }
    
    @ViewBuilder
    private var loadingView: some View {
        HStack(spacing: themeProvider.theme.spacing.sm) {
            ProgressView()
                .scaleEffect(0.8)
                .tint(themeProvider.theme.colors.cadaEuroAccent)
            
            Text("A calcular...")
                .font(themeProvider.theme.typography.totalPrice)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
        }
    }
    
    @ViewBuilder
    private var menuActions: some View {
        Button("Guardar lista") {
            onSaveList()
        }
        
        Button("Nova lista") {
            onNewList()
        }
        
        Button("Cancelar", role: .cancel) {
            // Dispensa automática
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalState: TotalDisplayState {
        if isLoading { return .loading }
        if total == 0 { return .empty }
        if total >= 1000 { return .large }
        return .normal
    }
    
    private var formattedTotal: String {
        // ✅ USAR DoubleExtensions: Formatação premium para display principal
        return total.asTotalDisplayPrice
    }
    
    private var totalColor: Color {
        // ✅ Sempre usa cor accent (azul) - nunca vermelha
        return themeProvider.theme.colors.cadaEuroAccent
    }
    
    private var accessibilityLabel: String {
        if isLoading {
            return "Total da lista: A calcular"
        }
        // ✅ USAR DoubleExtensions: Acessibilidade natural
        return "Total da lista: \(total.asCurrencyAccessible)"
    }
    
    private var accessibilityHint: String {
        if isLoading {
            return "Aguarde o cálculo do total"
        }
        return "Prima e mantenha premido para opções da lista"
    }
}

// MARK: - Previews

#Preview("Total Display - Normal") {
    VStack(spacing: 24) {
        TotalDisplay(total: 45.67) {
            print("Save list")
        } onNewList: {
            print("New list")
        }
        
        TotalDisplay(total: 0.00) {
            print("Save empty list")
        } onNewList: {
            print("New list")
        }
        
        TotalDisplay(total: 1250.89) {
            print("Save large list")
        } onNewList: {
            print("New list")
        }
    }
    .padding()
    // ✅ Background aplicado no preview para testar
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("Total Display - Loading") {
    TotalDisplay(total: 123.45, isLoading: true) {
        print("Save list")
    } onNewList: {
        print("New list")
    }
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("Total Display - Dark Mode") {
    VStack(spacing: 24) {
        TotalDisplay(total: 89.99) {
            print("Save list")
        } onNewList: {
            print("New list")
        }
        
        TotalDisplay(total: 1500.00) {
            print("Save large list")
        } onNewList: {
            print("New list")
        }
        
        TotalDisplay(total: 25.50, isLoading: true) {
            print("Save loading")
        } onNewList: {
            print("New list")
        }
    }
    .padding()
    .background(ThemeProvider.darkPreview.theme.colors.cadaEuroBackground)
    .themeProvider(.darkPreview)
    .preferredColorScheme(.dark)
}

#Preview("Total Display - Empty State") {
    TotalDisplay(total: 0.00) {
        print("Save empty list")
    } onNewList: {
        print("New list")
    }
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("Total Display - States Comparison") {
    VStack(spacing: 16) {
        // Empty
        TotalDisplay(total: 0.00) { } onNewList: { }
        
        // Normal
        TotalDisplay(total: 67.85) { } onNewList: { }
        
        // Large
        TotalDisplay(total: 1234.56) { } onNewList: { }
        
        // Loading
        TotalDisplay(total: 45.67, isLoading: true) { } onNewList: { }
    }
    .padding()
    .background(ThemeProvider.darkPreview.theme.colors.cadaEuroBackground)
    .themeProvider(.darkPreview)
    .preferredColorScheme(.dark)
}
