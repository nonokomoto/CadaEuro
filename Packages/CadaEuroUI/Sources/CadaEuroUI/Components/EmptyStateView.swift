import SwiftUI
import CadaEuroKit

/// Componente para exibir estados vazios em listas ou ecrãs
public struct EmptyStateView: View {
    @Environment(\.themeProvider) private var themeProvider
    
    /// Nome do ícone SF Symbols
    private let iconName: String
    
    /// Título do estado vazio
    private let title: String
    
    /// Descrição do estado vazio
    private let description: String
    
    /// Texto do botão de ação (opcional)
    private let buttonTitle: String?
    
    /// Ação a ser executada quando o botão for pressionado
    private let action: (() -> Void)?
    
    /// Estado de animação do ícone
    @State private var iconScale: CGFloat = 0.8
    @State private var iconOpacity: Double = 0.0
    
    /// Estado de animação do texto
    @State private var textOpacity: Double = 0.0
    
    /// Estado de animação do botão
    @State private var buttonOpacity: Double = 0.0
    @State private var buttonScale: CGFloat = 0.9
    
    /// Estado de pressionamento do botão
    @State private var isButtonPressed: Bool = false
    
    /// Inicializador do componente
    /// - Parameters:
    ///   - iconName: Nome do ícone SF Symbols
    ///   - title: Título do estado vazio
    ///   - description: Descrição do estado vazio
    ///   - buttonTitle: Texto do botão de ação (opcional)
    ///   - action: Ação a ser executada quando o botão for pressionado
    public init(
        iconName: String,
        title: String,
        description: String,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.iconName = iconName
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: themeProvider.theme.spacing.xl) {
            // Ícone
            Image(systemName: iconName)
                .font(.system(size: 70))
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
                .accessibilityHidden(true)
            
            // Textos
            VStack(spacing: themeProvider.theme.spacing.sm) {
                Text(title)
                    .font(themeProvider.theme.typography.titleMedium)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(themeProvider.theme.typography.bodyMedium)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .opacity(textOpacity)
            
            // Botão de ação (opcional)
            if let buttonTitle = buttonTitle, let action = action {
                Button(action: {
                    HapticManager.shared.feedback(.medium)
                    action()
                }) {
                    Text(buttonTitle)
                        .font(themeProvider.theme.typography.bodyMedium)
                        .foregroundColor(.white)
                        .padding(.vertical, themeProvider.theme.spacing.sm)
                        .padding(.horizontal, themeProvider.theme.spacing.xl)
                        .background(
                            RoundedRectangle(cornerRadius: themeProvider.theme.border.smallButtonRadius)
                                .fill(themeProvider.theme.colors.cadaEuroAccent)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isButtonPressed ? themeProvider.theme.animation.pressedScale : buttonScale)
                .opacity(buttonOpacity)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            withAnimation(themeProvider.theme.animation.standard) {
                                isButtonPressed = true
                            }
                        }
                        .onEnded { _ in
                            withAnimation(themeProvider.theme.animation.standard) {
                                isButtonPressed = false
                            }
                        }
                )
            }
        }
        .padding(.horizontal, themeProvider.theme.spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(description)")
        .accessibilityAddTraits(.isStaticText)
        .accessibilityAction(named: buttonTitle ?? "") {
            action?()
        }
        .onAppear {
            animateAppearance()
        }
    }
    
    /// Anima a aparência dos elementos na sequência: ícone, texto, botão
    private func animateAppearance() {
        // Anima o ícone
        withAnimation(themeProvider.theme.animation.standard.delay(0.1)) {
            iconOpacity = 1.0
            iconScale = 1.0
        }
        
        // Anima o texto
        withAnimation(themeProvider.theme.animation.standard.delay(0.3)) {
            textOpacity = 1.0
        }
        
        // Anima o botão
        if buttonTitle != nil && action != nil {
            withAnimation(themeProvider.theme.animation.standard.delay(0.5)) {
                buttonOpacity = 1.0
                buttonScale = 1.0
            }
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var showWithButton = true
        
        var body: some View {
            VStack {
                if showWithButton {
                    EmptyStateView(
                        iconName: "archivebox",
                        title: "Sem listas guardadas",
                        description: "As suas listas guardadas aparecerão aqui. Guarde uma lista para começar a acompanhar os seus gastos ao longo do tempo.",
                        buttonTitle: "Criar Nova Lista",
                        action: {
                            withAnimation {
                                showWithButton.toggle()
                            }
                        }
                    )
                } else {
                    EmptyStateView(
                        iconName: "chart.bar.xaxis",
                        title: "Sem dados estatísticos",
                        description: "Complete e guarde algumas listas de compras para começar a ver estatísticas sobre os seus gastos.",
                        buttonTitle: nil,
                        action: nil
                    )
                    .onTapGesture {
                        withAnimation {
                            showWithButton.toggle()
                        }
                    }
                }
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
