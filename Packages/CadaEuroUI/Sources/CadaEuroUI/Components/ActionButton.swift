import SwiftUI
import CadaEuroKit

/// Tamanhos disponíveis para o botão de ação
public enum ActionButtonSize {
    /// Tamanho pequeno (altura: 36pt)
    case small
    
    /// Tamanho médio (altura: 44pt)
    case medium
    
    /// Tamanho grande (altura: 56pt)
    case large
    
    /// Retorna a altura do botão conforme o tamanho
    var height: CGFloat {
        switch self {
        case .small: return 36
        case .medium: return 44
        case .large: return 56
        }
    }
    
    /// Retorna o padding horizontal do botão conforme o tamanho
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 20
        case .large: return 24
        }
    }
    
    /// Retorna o tamanho da fonte conforme o tamanho do botão
    var font: Font {
        switch self {
        case .small: return .system(size: 14, weight: .medium)
        case .medium: return .system(size: 16, weight: .medium)
        case .large: return .system(size: 18, weight: .medium)
        }
    }
}

/// Variantes de estilo para o botão de ação
public enum ActionButtonStyle {
    /// Estilo primário (fundo colorido, texto branco)
    case primary
    
    /// Estilo secundário (fundo transparente, borda colorida)
    case secondary
    
    /// Estilo terciário (apenas texto colorido)
    case tertiary
    
    /// Estilo destrutivo (vermelho)
    case destructive
}

/// Botão de ação primária estilizado para a aplicação CadaEuro
public struct ActionButton: View {
    @Environment(\.themeProvider) private var themeProvider
    @Environment(\.isEnabled) private var isEnabled
    
    /// Título do botão
    private let title: String
    
    /// Ícone do botão (opcional)
    private let icon: String?
    
    /// Tamanho do botão
    private let size: ActionButtonSize
    
    /// Estilo do botão
    private let style: ActionButtonStyle
    
    /// Largura total (preenche o espaço disponível)
    private let fullWidth: Bool
    
    /// Ação a ser executada quando o botão for pressionado
    private let action: () -> Void
    
    /// Estado de pressionamento do botão
    @State private var isPressed: Bool = false
    
    /// Inicializador do componente
    /// - Parameters:
    ///   - title: Título do botão
    ///   - icon: Ícone SF Symbols (opcional)
    ///   - size: Tamanho do botão
    ///   - style: Estilo do botão
    ///   - fullWidth: Se o botão deve ocupar toda a largura disponível
    ///   - action: Ação a ser executada quando o botão for pressionado
    public init(
        title: String,
        icon: String? = nil,
        size: ActionButtonSize = .medium,
        style: ActionButtonStyle = .primary,
        fullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.size = size
        self.style = style
        self.fullWidth = fullWidth
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            provideFeedback()
            action()
        }) {
            HStack(spacing: themeProvider.theme.spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(size.font)
                        .foregroundColor(foregroundColor)
                }
                
                Text(title)
                    .font(size.font)
                    .foregroundColor(foregroundColor)
            }
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(backgroundColor)
            .cornerRadius(themeProvider.theme.border.smallButtonRadius)
            .overlay(
                RoundedRectangle(cornerRadius: themeProvider.theme.border.smallButtonRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .opacity(isEnabled ? 1.0 : 0.5)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? themeProvider.theme.animation.pressedScale : 1.0)
        .animation(themeProvider.theme.animation.standard, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if isEnabled {
                        withAnimation {
                            isPressed = true
                        }
                    }
                }
                .onEnded { _ in
                    if isEnabled {
                        withAnimation {
                            isPressed = false
                        }
                    }
                }
        )
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
    
    /// Fornece feedback háptico conforme o estilo do botão
    private func provideFeedback() {
        switch style {
        case .primary:
            HapticManager.shared.feedback(.medium)
        case .secondary:
            HapticManager.shared.feedback(.light)
        case .tertiary:
            HapticManager.shared.feedback(.light)
        case .destructive:
            HapticManager.shared.feedback(.heavy)
        }
    }
    
    /// Cor de fundo do botão conforme o estilo
    private var backgroundColor: Color {
        if !isEnabled {
            return style == .primary ? themeProvider.theme.colors.cadaEuroTextTertiary : .clear
        }
        
        switch style {
        case .primary:
            return themeProvider.theme.colors.cadaEuroAccent
        case .secondary, .tertiary:
            return .clear
        case .destructive:
            return isPressed ? themeProvider.theme.colors.cadaEuroError.opacity(0.9) : themeProvider.theme.colors.cadaEuroError
        }
    }
    
    /// Cor do texto e ícone conforme o estilo
    private var foregroundColor: Color {
        if !isEnabled {
            return style == .primary ? .white : themeProvider.theme.colors.cadaEuroTextTertiary
        }
        
        switch style {
        case .primary:
            return .white
        case .secondary:
            return themeProvider.theme.colors.cadaEuroAccent
        case .tertiary:
            return themeProvider.theme.colors.cadaEuroAccent
        case .destructive:
            return style == .primary ? .white : themeProvider.theme.colors.cadaEuroError
        }
    }
    
    /// Cor da borda conforme o estilo
    private var borderColor: Color {
        if !isEnabled {
            return style == .secondary ? themeProvider.theme.colors.cadaEuroTextTertiary : .clear
        }
        
        switch style {
        case .secondary:
            return themeProvider.theme.colors.cadaEuroAccent
        case .destructive:
            return style == .secondary ? themeProvider.theme.colors.cadaEuroError : .clear
        default:
            return .clear
        }
    }
    
    /// Largura da borda conforme o estilo
    private var borderWidth: CGFloat {
        switch style {
        case .secondary:
            return themeProvider.theme.border.standardBorderWidth
        default:
            return 0
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var isEnabled = true
        
        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    Group {
                        Text("Botões Primários")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ActionButton(
                            title: "Botão Pequeno",
                            size: .small,
                            style: .primary,
                            action: {}
                        )
                        
                        ActionButton(
                            title: "Botão Médio",
                            icon: "plus",
                            size: .medium,
                            style: .primary,
                            action: {}
                        )
                        
                        ActionButton(
                            title: "Botão Grande",
                            icon: "checkmark",
                            size: .large,
                            style: .primary,
                            fullWidth: true,
                            action: {}
                        )
                    }
                    
                    Group {
                        Text("Botões Secundários")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                        
                        ActionButton(
                            title: "Botão Secundário",
                            icon: "arrow.right",
                            style: .secondary,
                            action: {}
                        )
                        
                        ActionButton(
                            title: "Botão Terciário",
                            style: .tertiary,
                            action: {}
                        )
                    }
                    
                    Group {
                        Text("Botões Destrutivos")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                        
                        ActionButton(
                            title: "Apagar",
                            icon: "trash",
                            style: .destructive,
                            action: {}
                        )
                        
                        ActionButton(
                            title: "Cancelar Subscrição",
                            style: .destructive,
                            fullWidth: true,
                            action: {}
                        )
                    }
                    
                    Group {
                        Text("Estados")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                        
                        Toggle("Ativar/Desativar Botões", isOn: $isEnabled)
                            .padding(.bottom)
                        
                        ActionButton(
                            title: "Botão Desativado",
                            icon: "xmark",
                            style: .primary,
                            action: {}
                        )
                        .disabled(!isEnabled)
                        
                        ActionButton(
                            title: "Secundário Desativado",
                            style: .secondary,
                            action: {}
                        )
                        .disabled(!isEnabled)
                    }
                }
                .padding()
            }
            .background(themeProvider.theme.colors.cadaEuroBackground)
            .withThemeProvider(ThemeProvider())
        }
        
        private var themeProvider: ThemeProvider {
            ThemeProvider()
        }
    }
    
    return PreviewWrapper()
}
