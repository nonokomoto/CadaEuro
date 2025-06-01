import SwiftUI

/// Tipo de estado vazio disponível na aplicação CadaEuro
public enum EmptyStateType {
    case newShoppingList
    case savedLists
    case statistics
    case searchResults
    
    public var systemImage: String {
        switch self {
        case .newShoppingList: return "cart.badge.plus"
        case .savedLists: return "archivebox"
        case .statistics: return "chart.bar.xaxis"
        case .searchResults: return "magnifyingglass"
        }
    }
    
    public var title: String {
        switch self {
        case .newShoppingList: return "Comece a sua lista"
        case .savedLists: return "Nenhuma lista guardada"
        case .statistics: return "Sem dados estatísticos"
        case .searchResults: return "Nenhum resultado encontrado"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .newShoppingList: return "Adicione produtos usando a câmara, microfone ou entrada manual"
        case .savedLists: return "As suas listas guardadas aparecerão aqui"
        case .statistics: return "Complete algumas listas para ver as suas estatísticas"
        case .searchResults: return "Tente usar termos diferentes"
        }
    }
}

/// View de estado vazio premium para CadaEuro
public struct EmptyStateView: View {
    @Environment(\.themeProvider) private var themeProvider
    
    private let type: EmptyStateType
    
    @State private var isAnimating = false
    
    public init(type: EmptyStateType) {
        self.type = type
    }
    
    public var body: some View {
        VStack(spacing: themeProvider.theme.spacing.xl) {
            // Ícone principal com animação
            ZStack {
                // Ícone principal
                Image(systemName: type.systemImage)
                    .font(.system(size: 30, weight: .light))
                    .scaleEffect(isAnimating ? 1.02 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            
            // Título e subtítulo
            VStack(spacing: themeProvider.theme.spacing.sm) {
                Text(type.subtitle)
                    .font(themeProvider.theme.typography.bodySmall)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, themeProvider.theme.spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeProvider.theme.colors.cadaEuroBackground)
        .onAppear {
            // Inicia animação após pequeno delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAnimating = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }
    
    // MARK: - Computed Properties
    private var iconBackgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                themeProvider.theme.colors.cadaEuroAccent.opacity(0.1),
                themeProvider.theme.colors.cadaEuroAccent.opacity(0.05)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var accessibilityDescription: String {
        "\(type.title). \(type.subtitle)"
    }
}

#Preview("Empty State - New List") {
    EmptyStateView(type: .newShoppingList)
        .themeProvider(.preview)
}

#Preview("Empty State - Saved Lists") {
    EmptyStateView(type: .savedLists)
        .themeProvider(.preview)
}

#Preview("Empty State - Statistics") {
    EmptyStateView(type: .statistics)
        .themeProvider(.preview)
}

#Preview("Empty State - Search") {
    EmptyStateView(type: .searchResults)
        .themeProvider(.preview)
}

#Preview("Empty State Dark") {
    EmptyStateView(type: .newShoppingList)
        .themeProvider(.darkPreview)
        .preferredColorScheme(.dark)
}
