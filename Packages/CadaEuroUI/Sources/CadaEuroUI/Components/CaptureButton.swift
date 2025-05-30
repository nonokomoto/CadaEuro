import SwiftUI
import CadaEuroKit

/// Tipo de botão de captura
public enum CaptureButtonType {
    case scanner
    case voice
    case manual
    
    /// Retorna o ícone correspondente ao tipo de botão
    var icon: String {
        switch self {
        case .scanner: return "camera.fill"
        case .voice: return "mic.fill"
        case .manual: return "keyboard"
        }
    }
    
    /// Retorna o título correspondente ao tipo de botão
    var title: String {
        switch self {
        case .scanner: return "Capturar com câmara"
        case .voice: return "Gravar com microfone"
        case .manual: return "Adicionar manualmente"
        }
    }
    
    /// Retorna a dica de acessibilidade correspondente ao tipo de botão
    var accessibilityHint: String {
        switch self {
        case .scanner: return "Abre scanner para capturar preços com a câmara"
        case .voice: return "Inicia gravação de voz para capturar produtos"
        case .manual: return "Abre formulário para adicionar produto manualmente"
        }
    }
}

/// Componente de botão de captura circular para a aplicação CadaEuro
/// Usado para os diferentes métodos de captura (câmara, voz, entrada manual)
public struct CaptureButton: View {
    @Environment(\.themeProvider) private var themeProvider
    
    /// Tipo de botão de captura
    private let type: CaptureButtonType
    
    /// Indica se o botão está ativo
    private let isActive: Bool
    
    /// Ação executada ao tocar no botão
    private let action: () -> Void
    
    /// Estado de animação
    @State private var isPressed: Bool = false
    
    /// Inicializador do componente
    /// - Parameters:
    ///   - type: Tipo de botão de captura
    ///   - isActive: Indica se o botão está ativo (padrão: true)
    ///   - action: Ação executada ao tocar no botão
    public init(
        type: CaptureButtonType,
        isActive: Bool = true,
        action: @escaping () -> Void
    ) {
        self.type = type
        self.isActive = isActive
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            hapticFeedback(.medium)
            action()
        }) {
            VStack(spacing: 8) {
                // Ícone
                Image(systemName: type.icon)
                    .font(themeProvider.theme.typography.titleMedium)
                    .foregroundColor(iconColor)
                    .frame(width: 70, height: 70)
                    .background(
                        Circle()
                            .fill(backgroundColor)
                            .shadow(
                                color: Color.black.opacity(0.15),
                                radius: themeProvider.theme.border.shadowRadius1,
                                x: 0,
                                y: themeProvider.theme.border.shadowYOffset1
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(borderColor, lineWidth: themeProvider.theme.border.standardBorderWidth)
                    )
                
                // Texto (opcional, pode ser removido se preferir apenas ícones)
                Text(type.title)
                    .font(themeProvider.theme.typography.caption)
                    .foregroundColor(textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .buttonStyle(CaptureButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(type.title)
        .accessibilityHint(type.accessibilityHint)
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(5) // Prioridade média para VoiceOver
        .disabled(!isActive)
        .opacity(isActive ? 1.0 : 0.5)
    }
    
    /// Cor de fundo do botão
    private var backgroundColor: Color {
        isActive 
            ? themeProvider.theme.colors.cadaEuroComponentBackground
            : themeProvider.theme.colors.cadaEuroComponentBackground.opacity(0.7)
    }
    
    /// Cor do ícone
    private var iconColor: Color {
        isActive
            ? themeProvider.theme.colors.cadaEuroAccent
            : themeProvider.theme.colors.cadaEuroTextTertiary
    }
    
    /// Cor da borda
    private var borderColor: Color {
        isActive
            ? themeProvider.theme.colors.cadaEuroAccent.opacity(0.3)
            : themeProvider.theme.colors.cadaEuroTextTertiary.opacity(0.3)
    }
    
    /// Cor do texto
    private var textColor: Color {
        isActive
            ? themeProvider.theme.colors.cadaEuroTextPrimary
            : themeProvider.theme.colors.cadaEuroTextTertiary
    }
    
    /// Fornece feedback háptico
    private func hapticFeedback(_ type: HapticManager.FeedbackType) {
        HapticManager.shared.feedback(type)
    }
}

/// Estilo personalizado para o botão de captura
struct CaptureButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: themeProvider.theme.animation.shortDuration), value: configuration.isPressed)
    }
}

#Preview {
    HStack(spacing: 40) {
        CaptureButton(type: .scanner) {
            print("Scanner tapped")
        }
        
        CaptureButton(type: .voice) {
            print("Voice tapped")
        }
        
        CaptureButton(type: .manual, isActive: false) {
            print("Manual tapped")
        }
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(themeProvider.theme.colors.cadaEuroBackground)
    .withThemeProvider(ThemeProvider())
}
