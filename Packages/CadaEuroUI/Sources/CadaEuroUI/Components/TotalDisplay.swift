import SwiftUI

/// Componente que exibe o total da lista de compras
public struct TotalDisplay: View {
    @Environment(\.themeProvider) private var themeProvider
    
    /// Valor total a ser exibido
    private let total: Double
    
    /// Ação executada ao fazer um long press no total
    private let onLongPress: () -> Void
    
    /// Indica se a animação de pulsação deve ser exibida
    @State private var pulseAnimation: Bool = false
    
    /// Inicializador do componente
    /// - Parameters:
    ///   - total: Valor total a ser exibido
    ///   - onLongPress: Ação executada ao fazer um long press no total
    public init(total: Double, onLongPress: @escaping () -> Void) {
        self.total = total
        self.onLongPress = onLongPress
    }
    
    public var body: some View {
        Text("€\(String(format: "%.2f", total))")
            .font(themeProvider.theme.typography.totalPrice)
            .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
            .padding(.top, themeProvider.theme.spacing.totalTopMargin)
            .contentShape(Rectangle())
            .scaleEffect(pulseAnimation ? themeProvider.theme.animation.updatedTotalScale : 1.0)
            .animation(themeProvider.theme.animation.standard, value: pulseAnimation)
            .accessibilityLabel("Total da lista: \(String(format: "%.2f", total)) euros")
            .accessibilityHint("Prima e mantenha premido para opções")
            .accessibilityAddTraits(.isHeader)
            .accessibilitySortPriority(9) // Alta prioridade para VoiceOver
            .onTapGesture(count: 2) {
                // Duplo toque também aciona o menu para melhorar acessibilidade
                onLongPress()
                hapticFeedback(.medium)
            }
            .onLongPressGesture {
                onLongPress()
                hapticFeedback(.medium)
            }
            .overlay(
                // Efeito de glow apenas no modo escuro
                Circle()
                    .fill(themeProvider.theme.colors.cadaEuroTotalPrice)
                    .blur(radius: themeProvider.theme.border.glowRadius)
                    .opacity(0.7)
                    .scaleEffect(1.5)
                    .allowsHitTesting(false)
            )
            .onAppear {
                // Animação de pulsação ao aparecer
                animatePulse()
            }
    }
    
    /// Executa a animação de pulsação
    private func animatePulse() {
        pulseAnimation = true
        
        // Reseta a animação após um breve período
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            pulseAnimation = false
        }
    }
    
    /// Fornece feedback háptico
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    VStack {
        TotalDisplay(total: 23.68) {
            print("Long press on total")
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(UIColor.systemBackground))
    .withThemeProvider(ThemeProvider())
}


