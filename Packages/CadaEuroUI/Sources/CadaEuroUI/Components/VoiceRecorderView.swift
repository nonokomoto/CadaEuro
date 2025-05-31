import SwiftUI
import Speech
import CadaEuroKit  

/// Estados do gravador de voz estilo WhatsApp
public enum VoiceRecorderState: Sendable, Equatable {
    case idle           // Pronto para gravar
    case recording      // Gravação ativa (botão pressionado)
    case recorded       // Gravação finalizada, aguardando decisão
    case processing     // Processando transcrição
    case transcribed    // Texto reconhecido
    case error(VoiceRecorderError)
    
    // ✅ Conformidade Equatable manual para enum com associated values
    public static func == (lhs: VoiceRecorderState, rhs: VoiceRecorderState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.recording, .recording), (.recorded, .recorded), 
             (.processing, .processing), (.transcribed, .transcribed):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
    
    public var isInteractive: Bool {
        switch self {
        case .processing: return false
        default: return true
        }
    }
}

/// Erros do gravador de voz (wrapper do CaptureError)
public enum VoiceRecorderError: LocalizedError, Sendable, Equatable {
    case permissionDenied
    case recognitionNotAvailable
    case recordingTooShort
    case transcriptionFailed
    case microphoneUnavailable
    case networkUnavailable
    
    public var errorDescription: String? {
        switch self {
        case .permissionDenied: return "Permissão de microfone necessária"
        case .recognitionNotAvailable: return "Reconhecimento de fala indisponível"
        case .recordingTooShort: return "Gravação muito curta"
        case .transcriptionFailed: return "Não consegui perceber o que disse"
        case .microphoneUnavailable: return "Microfone não disponível"
        case .networkUnavailable: return "Sem ligação a rede"
        }
    }
    
    /// Converte VoiceRecorderError para CaptureError centralizado
    public var asCaptureError: CaptureError {
        switch self {
        case .permissionDenied: return .microphonePermissionDenied
        case .recognitionNotAvailable: return .speechRecognitionFailed
        case .recordingTooShort: return .speechRecognitionFailed
        case .transcriptionFailed: return .speechRecognitionFailed
        case .microphoneUnavailable: return .microphoneUnavailable
        case .networkUnavailable: return .networkUnavailable
        }
    }
}

/// Interface de gravação de voz inline estilo WhatsApp
public struct VoiceRecorderView: View {
    @Environment(\.themeProvider) private var themeProvider
    
    private let onTranscriptionComplete: (String) -> Void
    private let onError: (VoiceRecorderError) -> Void
    private let onFallbackToManual: (() -> Void)?
    
    @State private var recorderState: VoiceRecorderState = .idle
    @State private var isLongPressing = false
    @State private var recordingDuration: TimeInterval = 0.0
    @State private var audioLevel: Float = 0.0
    @State private var transcribedText: String = ""
    @State private var timer: Timer?
    @State private var currentError: VoiceRecorderError?
    
    // MARK: - Initializer
    
    public init(
        onTranscriptionComplete: @escaping (String) -> Void,
        onError: @escaping (VoiceRecorderError) -> Void,
        onFallbackToManual: (() -> Void)? = nil
    ) {
        self.onTranscriptionComplete = onTranscriptionComplete
        self.onError = onError
        self.onFallbackToManual = onFallbackToManual
    }
    
    public var body: some View {
        HStack(spacing: themeProvider.theme.spacing.lg) {
            // Botão do microfone (sempre visível)
            microphoneButton
            
            // Interface de gravação expandida
            if recorderState != .idle {
                recordingInterface
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(themeProvider.theme.animation.spring, value: recorderState)
        .captureErrorHandler(
            error: currentError?.asCaptureError,
            onRetry: {
                clearErrorAndRetry()
            },
            onCancel: {
                clearErrorAndCancel()
            },
            onFallback: onFallbackToManual != nil ? {
                clearErrorAndFallback()
            } : nil
        )
        .onAppear {
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == nil {
                requestPermissions()
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var microphoneButton: some View {
        Button(action: {}) {
            ZStack {
                Circle()
                    .fill(buttonBackgroundGradient)
                    .frame(width: 64, height: 64)
                    .scaleEffect(isLongPressing ? 1.1 : 1.0)
                    .shadow(
                        color: shadowColor,
                        radius: isLongPressing ? 12 : 6,
                        x: 0,
                        y: isLongPressing ? 6 : 3
                    )
                
                Image(systemName: microphoneIcon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .scaleEffect(isLongPressing ? 0.9 : 1.0)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(recorderState == .processing)
        .onLongPressGesture(minimumDuration: 0.0) { pressing in
            handleLongPressChange(pressing)
        } perform: {
            finishRecording()
        }
        .accessibilityLabel("Gravação de voz")
        .accessibilityHint("Prima e mantenha premido para gravar")
    }
    
    @ViewBuilder
    private var recordingInterface: some View {
        HStack(spacing: themeProvider.theme.spacing.lg) {
            // Audio visualizer
            if recorderState == .recording {
                audioVisualizerView
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Status e timer
            VStack(alignment: .leading, spacing: themeProvider.theme.spacing.xs) {
                HStack(spacing: themeProvider.theme.spacing.sm) {
                    // Indicador de gravação
                    if recorderState == .recording {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .scaleEffect(1.2)
                            .animation(
                                .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                value: recorderState
                            )
                    }
                    
                    // Timer ou status
                    Text(statusText)
                        .font(themeProvider.theme.typography.bodyMedium)
                        .fontWeight(.medium)
                        .foregroundColor(statusTextColor)
                }
                
                // Texto transcrito (se disponível)
                if case .transcribed = recorderState {
                    Text(transcribedText)
                        .font(themeProvider.theme.typography.bodySmall)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                        .lineLimit(2)
                        .transition(.opacity)
                }
            }
            
            Spacer()
            
            // Botões de ação (quando necessário)
            if recorderState == .recorded || recorderState == .transcribed {
                recordingActionsView
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(themeProvider.theme.spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: themeProvider.theme.border.buttonRadius)
                .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
                .shadow(color: themeProvider.theme.colors.cadaEuroTextTertiary.opacity(0.1), radius: 4)
        )
    }
    
    @ViewBuilder
    private var audioVisualizerView: some View {
        HStack(spacing: 2) {
            ForEach(0..<12, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.green)
                    .frame(width: 2, height: barHeight(for: index))
                    .animation(
                        .easeInOut(duration: 0.1)
                        .delay(Double(index) * 0.02),
                        value: audioLevel
                    )
            }
        }
        .frame(height: 24)
    }
    
    @ViewBuilder
    private var recordingActionsView: some View {
        HStack(spacing: themeProvider.theme.spacing.sm) {
            // Botão apagar
            Button(action: deleteRecording) {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeProvider.theme.colors.cadaEuroError)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(themeProvider.theme.colors.cadaEuroError.opacity(0.1))
                    )
            }
            
            // Botão enviar
            Button(action: sendRecording) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(themeProvider.theme.colors.cadaEuroAccent)
                    )
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var statusText: String {
        switch recorderState {
        case .recording: return formattedDuration
        case .recorded: return "Gravação concluída"
        case .processing: return "A processar..."
        case .transcribed: return "Texto reconhecido"
        case .error(let error): return error.localizedDescription
        default: return ""
        }
    }
    
    private var statusTextColor: Color {
        switch recorderState {
        case .error: return themeProvider.theme.colors.cadaEuroError
        case .transcribed: return themeProvider.theme.colors.cadaEuroAccent
        default: return themeProvider.theme.colors.cadaEuroTextPrimary
        }
    }
    
    private var buttonBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.green,
                Color.green.opacity(0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var shadowColor: Color {
        Color.green.opacity(0.3)
    }
    
    private var microphoneIcon: String {
        switch recorderState {
        case .recording: return "mic.fill"
        case .processing: return "waveform"
        default: return "mic.fill"
        }
    }
    
    private var formattedDuration: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Methods
    
    private func handleLongPressChange(_ pressing: Bool) {
        withAnimation(themeProvider.theme.animation.quick) {
            isLongPressing = pressing
        }
        
        if pressing {
            startRecording()
        }
    }
    
    private func startRecording() {
        // Verifica permissões antes de iniciar
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == nil else {
            // Preview mode - simula início de gravação
            recorderState = .recording
            recordingDuration = 0.0
            startTimer()
            return
        }
        
        // ✅ Condicional de compilação para multiplataforma
        #if os(iOS) || os(watchOS)
        // Verifica disponibilidade do microfone
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            Task { @MainActor in
                if granted {
                    recorderState = .recording
                    recordingDuration = 0.0
                    currentError = nil
                    startTimer()
                } else {
                    handleError(.permissionDenied)
                }
            }
        }
        #else
        // macOS/outras plataformas - simula permissão concedida
        recorderState = .recording
        recordingDuration = 0.0
        currentError = nil
        startTimer()
        #endif
    }
    
    private func finishRecording() {
        timer?.invalidate()
        timer = nil
        
        guard recordingDuration >= PerformanceConstants.minimumRecordingDuration else {  // ✅ USAR PerformanceConstants
            handleError(.recordingTooShort)
            return
        }
        
        recorderState = .recorded
        
        // ✅ MainActor isolation para UI updates
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.0))
            processRecording()
        }
    }
    
    private func processRecording() {
        // ✅ ADICIONADO: Analytics tracking
        print("📊 Analytics: \(CaptureMethod.voice.analyticsName) - processing_started")
        
        recorderState = .processing
        
        // ✅ MainActor isolation para updates de UI
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.0))
            
            // Simula diferentes tipos de erro baseado em probabilidade
            let errorProbability = Double.random(in: 0...1)
            
            if errorProbability > 0.7 { // 30% chance de erro
                let errors: [VoiceRecorderError] = [
                    .transcriptionFailed,
                    .recognitionNotAvailable,
                    .networkUnavailable
                ]
                let randomError = errors.randomElement()!
                handleError(randomError)
            } else {
                // Mock transcription com StringExtensions para parse
                let mockTranscriptions = [
                    "Leite Mimosa 1,29 euros",
                    "Pão de forma 85 cêntimos", 
                    "Queijo 3,50 euros",
                    "Iogurte natural 2,20 euros"
                ]
                
                let rawTranscription = mockTranscriptions.randomElement() ?? "Texto não reconhecido"
                
                // ✅ USAR StringExtensions: Parse inteligente de produto + preço
                let (product, price) = rawTranscription.extractProductAndPrice()
                
                // ✅ USAR StringExtensions: Normalização de nome do produto
                let normalizedProduct = product.normalizedProductName
                
                // ✅ USAR StringExtensions: Limpeza e formatação final
                transcribedText = "\(normalizedProduct) \(price?.asCurrency ?? "")"
                    .trimmedAndCleaned
                
                recorderState = .transcribed
            }
        }
    }
    
    private func handleError(_ error: VoiceRecorderError) {
        recorderState = .error(error)
        currentError = error
        onError(error)
    }
    
    // MARK: - Error Recovery Actions
    
    private func clearErrorAndRetry() {
        currentError = nil
        timer?.invalidate()
        timer = nil
        
        withAnimation(themeProvider.theme.animation.spring) {
            recorderState = .idle
            isLongPressing = false
        }
        
        // Tenta novamente após um breve delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            requestPermissions()
        }
    }
    
    private func clearErrorAndCancel() {
        currentError = nil
        cancelRecording()
    }
    
    private func clearErrorAndFallback() {
        currentError = nil
        cancelRecording()
        onFallbackToManual?()
    }
    
    private func cancelRecording() {
        timer?.invalidate()
        timer = nil
        
        withAnimation(themeProvider.theme.animation.spring) {
            recorderState = .idle
            isLongPressing = false
        }
    }
    
    private func deleteRecording() {
        timer?.invalidate()
        timer = nil
        
        withAnimation(themeProvider.theme.animation.spring) {
            recorderState = .idle
            isLongPressing = false
        }
    }
    
    private func sendRecording() {
        if case .transcribed = recorderState {
            // ✅ ADICIONADO: Analytics tracking
            print("📊 Analytics: \(CaptureMethod.voice.analyticsName) - transcription_success")
            
            // ✅ USAR StringExtensions: Parse final para envio
            let (product, price) = transcribedText.extractProductAndPrice()
            
            // ✅ USAR StringExtensions: Validação antes do envio
            if product.isValidProductName && (price?.isValidPrice ?? false) {
                onTranscriptionComplete(transcribedText)
            } else {
                // ✅ Fallback: Enviar texto original se parsing falhar
                onTranscriptionComplete(transcribedText)
            }
        }
        
        timer?.invalidate()
        timer = nil
        
        withAnimation(themeProvider.theme.animation.spring) {
            recorderState = .idle
            isLongPressing = false
        }
    }
    
    private func requestPermissions() {
        // ✅ Proteção adicional contra preview crashes
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == nil else { 
            return 
        }
        
        SFSpeechRecognizer.requestAuthorization { status in
            Task { @MainActor in
                switch status {
                case .authorized:
                    currentError = nil
                case .denied, .restricted:
                    handleError(.permissionDenied)
                case .notDetermined:
                    // Aguarda decisão do utilizador
                    break
                @unknown default:
                    handleError(.recognitionNotAvailable)
                }
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                recordingDuration += 0.1
                audioLevel = Float.random(in: 0.1...0.9)
                
                // ✅ USAR PerformanceConstants: Timeout máximo de gravação
                if recordingDuration >= PerformanceConstants.maximumRecordingDuration {
                    finishRecording()
                }
            }
        }
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        let baseHeight: CGFloat = 4
        let maxHeight: CGFloat = 24
        
        if recorderState == .recording {
            let normalizedLevel = CGFloat(audioLevel) * sin(Double(index) * 0.5 + recordingDuration * 2)
            return baseHeight + (maxHeight - baseHeight) * abs(normalizedLevel)
        }
        
        return baseHeight
    }
}

// MARK: - Import necessário para AVAudioSession (apenas iOS/watchOS)
#if os(iOS) || os(watchOS)
import AVFoundation
#endif

// MARK: - Previews

#Preview("Voice Recorder with Error Recovery") {
    VStack(spacing: 32) {
        Text("Voice Recorder com Error Handling")
            .font(.headline)
        
        VoiceRecorderView { transcription in
            print("Transcription: \(transcription)")
        } onError: { error in
            print("Voice error: \(error)")
        } onFallbackToManual: {
            print("Fallback to manual input")
        }
    }
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("Voice Recorder - Idle") {
    VStack(spacing: 32) {
        Text("Estado Idle")
            .font(.headline)
        
        VoiceRecorderView { transcription in
            print("Transcription: \(transcription)")
        } onError: { error in
            print("Error: \(error)")
        }
    }
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("Voice Recorder - Expanded States") {
    @Previewable @State var currentState: VoiceRecorderState = .recording
    
    VStack(spacing: 32) {
        Text("Estados Expandidos")
            .font(.headline)
        
        // Simula diferentes estados
        VStack(spacing: 16) {
            // Estado Recording
            HStack(spacing: 16) {
                Circle()
                    .fill(LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Image(systemName: "mic.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                    )
                
                HStack(spacing: 8) {
                    // Audio visualizer mock
                    HStack(spacing: 2) {
                        ForEach(0..<12, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.green)
                                .frame(width: 2, height: CGFloat.random(in: 4...24))
                        }
                    }
                    .frame(height: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Circle().fill(Color.red).frame(width: 8, height: 8)
                            Text("0:05")
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    
                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        // ✅ SwiftUI-Only: Usar themeProvider ao invés de UIKit
                        .fill(ThemeProvider.preview.theme.colors.cadaEuroComponentBackground)
                        .shadow(color: .black.opacity(0.1), radius: 4)
                )
            }
            
            // Estado Transcribed
            HStack(spacing: 16) {
                Circle()
                    .fill(LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Image(systemName: "mic.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                    )
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Texto reconhecido")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                        
                        Text("Leite Mimosa 1,29 euros")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button {} label: {
                            Image(systemName: "trash")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.red)
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(Color.red.opacity(0.1)))
                        }
                        
                        Button {} label: {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(Color.blue))
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        // ✅ SwiftUI-Only: Usar themeProvider ao invés de UIKit
                        .fill(ThemeProvider.preview.theme.colors.cadaEuroComponentBackground)
                        .shadow(color: .black.opacity(0.1), radius: 4)
                )
            }
        }
        
        Spacer()
    }
    .padding()
    // ✅ SwiftUI-Only: Substituir .systemGroupedBackground por tema
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}
