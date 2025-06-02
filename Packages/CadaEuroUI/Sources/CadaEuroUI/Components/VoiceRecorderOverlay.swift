import SwiftUI
import CadaEuroKit
import CadaEuroKit

/// Modal pequeno de gravação de voz contextual, estilo WhatsApp
/// Aparece próximo ao botão que o triggerou, 100% SwiftUI
public struct VoiceRecorderOverlay: View {
    @Environment(\.themeProvider) private var themeProvider
    
    // MARK: - Callbacks
    private let onTranscriptionComplete: (String) -> Void
    private let onCancel: () -> Void
    private let onError: (VoiceRecorderError) -> Void
    private let onFallbackToManual: (() -> Void)?
    
    // MARK: - State
    @State private var recorderState: VoiceRecorderState = .idle  // ✅ Iniciar em idle, não gravando
    @State private var currentError: VoiceRecorderError?
    @State private var recordingDuration: TimeInterval = 0.0
    @State private var audioLevel: Float = 0.0
    @State private var timer: Timer?
    @State private var animationOffset: CGFloat = 50 // Para animação de entrada
    @State private var initialScale: CGFloat = 0.1 // Para animação de crescimento estilo Apple
    
    // MARK: - Init
    public init(
        onTranscriptionComplete: @escaping (String) -> Void,
        onCancel: @escaping () -> Void,
        onError: @escaping (VoiceRecorderError) -> Void,
        onFallbackToManual: (() -> Void)? = nil
    ) {
        self.onTranscriptionComplete = onTranscriptionComplete
        self.onCancel = onCancel
        self.onError = onError
        self.onFallbackToManual = onFallbackToManual
    }
    
    // MARK: - Body
    public var body: some View {
        // Modal pequeno, estilo WhatsApp - adaptativo baseado no estado
        HStack(spacing: themeProvider.theme.spacing.md) {
            
            // Ícone de estado à esquerda
            stateIcon
            
            // Conteúdo central baseado no estado
            if recorderState == .recording {
                // Durante gravação: visualizador + timer
                recordingContentView
            } else if recorderState == .processing {
                // Durante processamento: spinner + texto
                processingContentView
            } else if recorderState == .error {
                // Em caso de erro: ícone de erro + mensagem
                if let error = currentError {
                    errorContentView(error)
                } else {
                    errorContentView(VoiceRecorderError.recordingFailed)
                }
            } else {
                // Estado inicial: instruções
                initialContentView
            }
            
            // Botão de ação à direita
            actionButton
        }
        .padding(.horizontal, themeProvider.theme.spacing.md)
        .padding(.vertical, themeProvider.theme.spacing.sm)
        .scaleEffect(initialScale)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .offset(y: animationOffset)
        .onAppear {
            // Animação de entrada estilo Apple - crescer a partir do botão
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                initialScale = 1.0
                animationOffset = 0
            }
            // ✅ Iniciar gravação automaticamente após aparecer
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                startRecording()
            }
        }
        .onDisappear {
            stopRecording()
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var stateIcon: some View {
        Image(systemName: stateIconName)
            .foregroundColor(stateIconColor)
            .font(.system(size: 16, weight: .medium))
            .frame(width: 24, height: 24)
    }
    
    @ViewBuilder
    private var recordingContentView: some View {
        // Visualizador de áudio compacto
        HStack(spacing: 2) {
            ForEach(0..<8, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.red)
                    .frame(width: 2, height: barHeight(for: index))
                    .animation(
                        .easeInOut(duration: 0.1)
                        .delay(Double(index) * 0.02),
                        value: audioLevel
                    )
            }
        }
        .frame(height: 20)
        
        // Timer compacto
        Text(formattedDuration)
            .font(themeProvider.theme.typography.caption)
            .fontWeight(.medium)
            .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
    }
    
    @ViewBuilder 
    private var processingContentView: some View {
        ProgressView()
            .scaleEffect(0.8)
        
        Text("Um segundo...")
            .font(themeProvider.theme.typography.caption)
            .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
    }
    
    @ViewBuilder
    private func errorContentView(_ error: VoiceRecorderError) -> some View {
        Text(error.localizedDescription)
            .font(themeProvider.theme.typography.caption)
            .foregroundColor(themeProvider.theme.colors.cadaEuroError)
            .lineLimit(2)
    }
    
    @ViewBuilder
    private var initialContentView: some View {
        Text("A iniciar gravação...")
            .font(themeProvider.theme.typography.caption)
            .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
    }
    
    @ViewBuilder
    private var actionButton: some View {
        Button {
            if recorderState == .recording {
                finishRecording()
            } else {
                onCancel()
            }
        } label: {
            Image(systemName: actionButtonIcon)
                .foregroundColor(actionButtonColor)
                .font(.system(size: 16))
        }
    }
    
    // MARK: - Computed Properties
    
    private var stateIconName: String {
        switch recorderState {
        case .idle: return "mic"
        case .recording: return "mic.fill"
        case .processing: return "waveform"
        case .error: return "exclamationmark.triangle"
        default: return "mic"
        }
    }
    
    private var stateIconColor: Color {
        switch recorderState {
        case .recording: return .red
        case .processing: return .blue
        case .error: return themeProvider.theme.colors.cadaEuroError
        default: return themeProvider.theme.colors.cadaEuroTextSecondary
        }
    }
    
    private var actionButtonIcon: String {
        switch recorderState {
        case .recording: return "stop.circle.fill"
        default: return "xmark.circle.fill"
        }
    }
    
    private var actionButtonColor: Color {
        switch recorderState {
        case .recording: return .red
        default: return themeProvider.theme.colors.cadaEuroTextSecondary
        }
    }
    
    // MARK: - Helper Methods
    
    private func startRecording() {
        recorderState = .recording
        recordingDuration = 0.0
        currentError = nil
        
        // Simular gravação com timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                recordingDuration += 0.1
                audioLevel = Float.random(in: 0.2...0.9)
                
                // Auto-stop após 30 segundos máximo
                if recordingDuration >= 30.0 {
                    finishRecording()
                }
            }
        }
    }
    
    private func stopRecording() {
        timer?.invalidate()
        timer = nil
    }
    
    private func finishRecording() {
        stopRecording()
        
        guard recordingDuration >= 1.0 else {
            onError(.recordingTooShort)
            return
        }
        
        // ✅ Processar gravação imediatamente após parar
        processRecording()
    }
    
    private func processRecording() {
        // Processar gravação
        recorderState = .processing
        
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            
            // ✅ Simulações realistas de transcrições de compras reais
            // Incluindo diferentes formatos de fala natural em português
            let mockTranscriptions = [
                "Comprei leite mimosa por dois euros e vinte e nove cêntimos",
                "Pão de forma integral custou um euro e quarenta e cinco",
                "Iogurte grego natural por três euros e dez cêntimos",
                "Maçãs royal gala dois quilos custaram quatro euros e cinquenta",
                "Azeite extra virgem por sete euros e noventa cêntimos",
                "Queijo fresco da marca presidente por dois euros e oitenta",
                "Ovos frescos meia dúzia custou um euro e setenta e cinco",
                "Banana da madeira um quilo por um euro e vinte",
                "Detergente da loiça fairy por três euros e quinze",
                "Arroz agulha cinco quilos por quatro euros e noventa",
                "Café delta por cinco euros e quarenta cêntimos",
                "Água das pedras seis garrafas por dois euros e cinquenta"
            ]
            
            let transcription = mockTranscriptions.randomElement() ?? "Produto genérico por um euro e cinquenta"
            
            CadaEuroLogger.info("Voice simulation completed", metadata: [
                "simulated_transcription": transcription,
                "processing_duration": "1.5s",
                "simulation_type": "realistic_portuguese_speech"
            ], category: .userInteraction)
            
            onTranscriptionComplete(transcription)
        }
    }
    
    private var formattedDuration: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        let baseHeight: CGFloat = 3
        let maxHeight: CGFloat = 16 // Mais compacto
        
        if recorderState == .recording {
            let normalizedLevel = CGFloat(audioLevel) * sin(Double(index) * 0.5 + recordingDuration * 2)
            return baseHeight + (maxHeight - baseHeight) * abs(normalizedLevel)
        }
        
        return baseHeight
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Voice Recorder Overlay") {
    VoiceRecorderOverlay(
        onTranscriptionComplete: { transcription in
            print("Transcrição: \(transcription)")
        },
        onCancel: {
            print("Cancelado")
        },
        onError: { error in
            print("Erro: \(error)")
        },
        onFallbackToManual: {
            print("Fallback para manual")
        }
    )
    .themeProvider(.preview)
}
#endif
