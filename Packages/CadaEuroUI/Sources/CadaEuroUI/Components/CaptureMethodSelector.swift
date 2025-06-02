import SwiftUI
import CadaEuroKit

/// Selector de métodos de captura com carrossel horizontal
public struct CaptureMethodSelector: View {
    @Environment(\.themeProvider) private var themeProvider
    
    private let onMethodSelected: (CaptureMethod) -> Void
    private let onVoiceLongPressStart: (() -> Void)?
    private let onVoiceLongPressEnd: (() -> Void)?
    
    @State private var currentPage = 0 // 0=scanner+voice, 1=manual
    @State private var dragOffset: CGFloat = 0
    
    // ✅ Estado para controlar visibilidade do botão de voz
    @Binding private var isVoiceButtonHidden: Bool
    
    public init(
        isVoiceButtonHidden: Binding<Bool> = .constant(false),
        onMethodSelected: @escaping (CaptureMethod) -> Void, 
        onVoiceLongPressStart: (() -> Void)? = nil,
        onVoiceLongPressEnd: (() -> Void)? = nil
    ) {
        self._isVoiceButtonHidden = isVoiceButtonHidden
        self.onMethodSelected = onMethodSelected
        self.onVoiceLongPressStart = onVoiceLongPressStart
        self.onVoiceLongPressEnd = onVoiceLongPressEnd
    }
    
    public var body: some View {
        VStack(spacing: themeProvider.theme.spacing.lg) {
            // Área dos botões com carrossel
            TabView(selection: $currentPage) {
                // Página 1: Scanner + Voice
                HStack(spacing: themeProvider.theme.spacing.xxl) {
                    CaptureButton(
                        method: .scanner,
                        isHidden: $isVoiceButtonHidden
                    ) {
                        handleMethodSelection(.scanner)
                    }
                    
                    CaptureButton(
                        method: .voice,
                        isHidden: $isVoiceButtonHidden,
                        action: { handleMethodSelection(.voice) },
                        onLongPressStart: onVoiceLongPressStart,
                        onLongPressEnd: onVoiceLongPressEnd
                    )
                }
                .captureButtonPosition(id: "capture_buttons_container")
                .frame(maxWidth: .infinity)
                .tag(0)
                
                // Página 2: Manual (centrado)
                HStack {
                    Spacer()
                    CaptureButton(method: .manual) {
                        handleMethodSelection(.manual)
                    }
                    Spacer()
                }
                .tag(1)
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #else
            .tabViewStyle(.automatic)
            #endif
            .frame(height: 80)
            .onChange(of: currentPage) { _, newPage in
                // ✅ SwiftUI-Only: Sem UIImpactFeedbackGenerator
                // Feedback háptico será adicionado via SensoryFeedback quando disponível
            }
            
            // Indicadores de página personalizados
            pageIndicators
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Selector de método de captura")
        .accessibilityHint("Deslize para ver mais opções ou toque nos botões para selecionar")
        .accessibilityValue(currentPageDescription)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var pageIndicators: some View {
        HStack(spacing: themeProvider.theme.spacing.sm) {
            // Scanner (sempre visível - azul)
            Circle()
                .fill(indicatorColor(for: .scanner))
                .frame(width: indicatorSize(for: .scanner), height: indicatorSize(for: .scanner))
                .scaleEffect(currentPage == 0 ? 1.2 : 1.0)
                .animation(themeProvider.theme.animation.spring, value: currentPage)
            
            // Voice (sempre visível - verde)
            Circle()
                .fill(indicatorColor(for: .voice))
                .frame(width: indicatorSize(for: .voice), height: indicatorSize(for: .voice))
                .scaleEffect(currentPage == 0 ? 1.2 : 1.0)
                .animation(themeProvider.theme.animation.spring, value: currentPage)
            
            // Manual (adaptativo - ativo quando página 1)
            Circle()
                .fill(indicatorColor(for: .manual))
                .frame(width: indicatorSize(for: .manual), height: indicatorSize(for: .manual))
                .scaleEffect(currentPage == 1 ? 1.2 : 1.0)
                .animation(themeProvider.theme.animation.spring, value: currentPage)
        }
        .padding(.vertical, themeProvider.theme.spacing.xs)
        .accessibilityHidden(true) // Evita redundância com VoiceOver
    }
    
    // MARK: - Methods
    
    private func handleMethodSelection(_ method: CaptureMethod) {
        // ✅ SwiftUI-Only: Sem UISelectionFeedbackGenerator
        // Feedback será implementado via SensoryFeedback modifier quando disponível
        
        // Chama callback
        onMethodSelected(method)
    }
    
    // MARK: - Computed Properties
    
    private func indicatorColor(for method: CaptureMethod) -> Color {
        switch method {
        case .scanner:
            return CaptureMethod.scanner.accentColor
        case .voice:
            return CaptureMethod.voice.accentColor
        case .manual:
            if currentPage == 1 {
                return CaptureMethod.manual.accentColor
            } else {
                return themeProvider.theme.colors.cadaEuroTextTertiary.opacity(0.4)
            }
        }
    }
    
    private func indicatorSize(for method: CaptureMethod) -> CGFloat {
        let baseSize: CGFloat = 8
        
        switch method {
        case .scanner, .voice:
            return baseSize
        case .manual:
            return currentPage == 1 ? baseSize : baseSize * 0.8
        }
    }
    
    private var currentPageDescription: String {
        switch currentPage {
        case 0:
            return "Página 1 de 2: Scanner e Microfone"
        case 1:
            return "Página 2 de 2: Entrada Manual"
        default:
            return "Página \(currentPage + 1)"
        }
    }
}

#Preview("Capture Method Selector") {
    VStack(spacing: 32) {
        Text("Selector de Métodos")
            .font(.title2)
            .fontWeight(.semibold)
        
        CaptureMethodSelector { method in
            print("Selected method: \(method.title)")
        }
        
        Spacer()
    }
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("Capture Method Selector Dark") {
    VStack(spacing: 32) {
        Text("Selector de Métodos")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
        
        CaptureMethodSelector { method in
            print("Selected method: \(method.title)")
        }
        
        Spacer()
    }
    .padding()
    .background(ThemeProvider.darkPreview.theme.colors.cadaEuroBackground)
    .themeProvider(.darkPreview)
    .preferredColorScheme(.dark)
}
