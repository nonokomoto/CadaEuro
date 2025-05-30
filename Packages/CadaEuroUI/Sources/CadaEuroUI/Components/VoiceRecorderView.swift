import SwiftUI
import CadaEuroKit

/// Estados de gravação de voz
public enum VoiceRecorderState {
    case idle
    case recording
    case processing
    case success
    case error
    
    /// Retorna a cor correspondente ao estado
    func color(theme: AppTheme) -> Color {
        switch self {
        case .idle:
            return theme.colors.cadaEuroTextTertiary
        case .recording:
            return theme.colors.cadaEuroError
        case .processing:
            return theme.colors.cadaEuroWarning
        case .success:
            return theme.colors.cadaEuroSuccess
        case .error:
            return theme.colors.cadaEuroError
        }
    }
    
    /// Retorna a mensagem correspondente ao estado
    var message: String {
        switch self {
        case .idle:
            return "Toque para iniciar gravação"
        case .recording:
            return "A gravar... Toque para parar"
        case .processing:
            return "A processar..."
        case .success:
            return "Gravação concluída"
        case .error:
            return "Erro na gravação"
        }
    }
}

/// Componente de interface para gravação de voz
/// Exibe uma animação de pulsação durante a gravação e feedback visual do estado
public struct VoiceRecorderView: View {
    @Environment(\.themeProvider) private var themeProvider
    
    /// Estado atual da gravação
    @Binding private var state: VoiceRecorderState
    
    /// Texto transcrito em tempo real
    @Binding private var transcribedText: String
    
    /// Nível de áudio (0.0 a 1.0)
    @Binding private var audioLevel: Double
    
    /// Ação executada ao tocar no botão de gravação
    private let onTap: () -> Void
    
    /// Estado de animação de pulsação
    @State private var isPulsing: Bool = false
    
    /// Inicializador do componente
    /// - Parameters:
    ///   - state: Estado atual da gravação
    ///   - transcribedText: Texto transcrito em tempo real
    ///   - audioLevel: Nível de áudio (0.0 a 1.0)
    ///   - onTap: Ação executada ao tocar no botão de gravação
    public init(
        state: Binding<VoiceRecorderState>,
        transcribedText: Binding<String>,
        audioLevel: Binding<Double>,
        onTap: @escaping () -> Void
    ) {
        self._state = state
        self._transcribedText = transcribedText
        self._audioLevel = audioLevel
        self.onTap = onTap
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            // Botão de gravação com animação
            Button(action: {
                hapticFeedback(state == .recording ? .rigid : .medium)
                onTap()
            }) {
                ZStack {
                    // Círculos de pulsação (apenas durante gravação)
                    if state == .recording {
                        ForEach(0..<3) { i in
                            Circle()
                                .stroke(state.color(theme: themeProvider.theme).opacity(0.5), lineWidth: 1)
                                .scaleEffect(isPulsing ? 1 + Double(i) * 0.4 : 0.6)
                                .opacity(isPulsing ? 0 : 0.7)
                                .animation(
                                    Animation.easeInOut(duration: themeProvider.theme.animation.longDuration)
                                        .repeatForever(autoreverses: false)
                                        .delay(Double(i) * 0.2),
                                    value: isPulsing
                                )
                        }
                    }
                    
                    // Círculo principal
                    Circle()
                        .fill(state.color(theme: themeProvider.theme))
                        .frame(width: 80, height: 80)
                        .shadow(color: state.color(theme: themeProvider.theme).opacity(0.3), radius: themeProvider.theme.border.shadowRadius1, x: 0, y: themeProvider.theme.border.shadowYOffset1)
                    
                    // Ícone de microfone
                    Image(systemName: state == .recording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .scaleEffect(state == .recording ? 1.0 + (audioLevel * 0.1) : 1.0)
            .animation(.spring(response: themeProvider.theme.animation.springResponse, dampingFraction: themeProvider.theme.animation.springDamping), value: audioLevel)
            
            // Mensagem de estado
            Text(state.message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                .padding(.top, 8)
            
            // Visualização do nível de áudio
            if state == .recording {
                audioLevelView
                    .frame(height: 40)
                    .padding(.top, 8)
            }
            
            // Texto transcrito
            if !transcribedText.isEmpty {
                transcriptionView
                    .padding(.top, 16)
            }
        }
        .padding(.horizontal, themeProvider.theme.spacing.lg)
        .padding(.vertical, themeProvider.theme.spacing.xl)
        .background(themeProvider.theme.colors.cadaEuroComponentBackground)
        .cornerRadius(themeProvider.theme.border.cardRadius)
        .shadow(color: Color.black.opacity(0.1), radius: themeProvider.theme.border.shadowRadius1, x: 0, y: themeProvider.theme.border.shadowYOffset1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Gravador de voz")
        .accessibilityHint(state.message)
        .accessibilityValue(transcribedText.isEmpty ? "Sem texto" : "Texto: \(transcribedText)")
        .onAppear {
            if state == .recording {
                startPulseAnimation()
            }
        }
        .onChange(of: state) { newState in
            if newState == .recording {
                startPulseAnimation()
            }
        }
    }
    
    /// Visualização do nível de áudio
    private var audioLevelView: some View {
        HStack(spacing: 3) {
            ForEach(0..<20, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(barColor(for: index))
                    .frame(width: 4, height: min(40, CGFloat(index + 1) * 2))
                    .scaleEffect(y: barScale(for: index), anchor: .bottom)
                    .animation(.spring(response: themeProvider.theme.animation.springResponse, dampingFraction: themeProvider.theme.animation.springDamping), value: audioLevel)
            }
        }
    }
    
    /// Visualização do texto transcrito
    private var transcriptionView: some View {
        ScrollView {
            Text(transcribedText)
                .font(.system(size: 16))
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(themeProvider.theme.colors.cadaEuroBackground.opacity(0.5))
                .cornerRadius(themeProvider.theme.border.smallButtonRadius)
        }
        .frame(maxHeight: 100)
    }
    
    /// Cor da barra de nível de áudio
    /// - Parameter index: Índice da barra
    /// - Returns: Cor da barra
    private func barColor(for index: Int) -> Color {
        let normalizedIndex = Double(index) / 20.0
        
        if normalizedIndex < 0.5 {
            return Color.green
        } else if normalizedIndex < 0.8 {
            return Color.yellow
        } else {
            return Color.red
        }
    }
    
    /// Escala da barra de nível de áudio
    /// - Parameter index: Índice da barra
    /// - Returns: Escala da barra
    private func barScale(for index: Int) -> CGFloat {
        let threshold = Double(index) / 20.0
        return audioLevel > threshold ? 1.0 : 0.1
    }
    
    /// Inicia a animação de pulsação
    private func startPulseAnimation() {
        isPulsing = true
    }
    
    /// Fornece feedback háptico
    /// - Parameter type: Tipo de feedback
    private func hapticFeedback(_ type: HapticManager.FeedbackType) {
        HapticManager.shared.feedback(type)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var state: VoiceRecorderState = .recording
        @State private var transcribedText: String = "Comprei leite por 1,99€ e pão por 0,85€"
        @State private var audioLevel: Double = 0.6
        
        var body: some View {
            ZStack {
                themeProvider.theme.colors.cadaEuroBackground
                    .edgesIgnoringSafeArea(.all)
                
                VoiceRecorderView(
                    state: $state,
                    transcribedText: $transcribedText,
                    audioLevel: $audioLevel
                ) {
                    state = state == .recording ? .processing : .recording
                }
                .padding()
            }
            .withThemeProvider(ThemeProvider())
        }
    }
    
    return PreviewWrapper()
}
