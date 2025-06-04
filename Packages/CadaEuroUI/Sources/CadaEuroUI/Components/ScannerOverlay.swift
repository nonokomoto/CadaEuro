import SwiftUI
import CadaEuroKit  

/// Estados simplificados do scanner para fluxo manual de photo capture
public enum ScannerState: Sendable, Equatable {
    case idle        // Preview com botão de captura
    case captured    // Foto tirada, pronta para OCR
    case processing  // OCR em processamento
    case error(ScannerError)
    
    /// Feedback mínimo apenas quando necessário
    public var feedbackText: String? {
        switch self {
        case .idle: return nil          // Sem texto no estado idle
        case .captured: return nil      // Flash visual é suficiente
        case .processing: return nil    // Loading spinner é suficiente
        case .error: return "Tentar novamente?"  // Apenas em erro
        }
    }
}

/// Tipos de erro específicos do scanner (wrapper do CaptureError)
public enum ScannerError: LocalizedError, Sendable, Equatable {
    case cameraUnavailable
    case recognitionFailed
    case processingTimeout
    case invalidData
    case permissionDenied
    case networkUnavailable
    
    public var errorDescription: String? {
        switch self {
        case .cameraUnavailable: return "Câmara não disponível 📱"
        case .recognitionFailed: return "Não consegui ler o texto 👀"
        case .processingTimeout: return "Demorou muito... tente novamente ⏰"
        case .invalidData: return "Isto não parece uma etiqueta 🤨"
        case .permissionDenied: return "Permissão da câmara necessária 🔐"
        case .networkUnavailable: return "Sem ligação a internet "
        }
    }
    
    /// Converte ScannerError para CaptureError centralizado
    public var asCaptureError: CaptureError {
        switch self {
        case .cameraUnavailable: return .cameraUnavailable
        case .recognitionFailed: return .ocrFailed
        case .processingTimeout: return .ocrFailed
        case .invalidData: return .ocrFailed
        case .permissionDenied: return .cameraPermissionDenied
        case .networkUnavailable: return .networkUnavailable
        }
    }
}

/// Interface de scanner OCR premium com animações e feedback visual
public struct ScannerOverlay: View {
    @Environment(\.themeProvider) private var themeProvider
    
    // MARK: - Properties
    private let onItemScanned: (ProductData) -> Void
    private let onCancel: () -> Void
    private let onError: ((ScannerError) -> Void)?
    private let onFallbackToManual: (() -> Void)?
    
    // MARK: - State
    @State private var scannerState: ScannerState = .idle
    @State private var currentError: ScannerError?
    @State private var flashEnabled = false
    @State private var isPressed = false
    
    // ✅ SwiftUI-Only: Removido - não precisamos mais calcular tamanho do frame
    // A câmera ocupa toda a tela como Apple Notes scanner
    
    public init(
        onItemScanned: @escaping (ProductData) -> Void,
        onCancel: @escaping () -> Void,
        onError: ((ScannerError) -> Void)? = nil,
        onFallbackToManual: (() -> Void)? = nil
    ) {
        self.onItemScanned = onItemScanned
        self.onCancel = onCancel
        self.onError = onError
        self.onFallbackToManual = onFallbackToManual
    }
    
    public var body: some View {
        ZStack {
            // Camera view (tela cheia) - sempre visível como background
            cameraBackground
            
            // Overlays mínimos conforme estado
            stateOverlays
            
            // Controlos essenciais
            essentialControls
        }
        .ignoresSafeArea() // Tela cheia como Apple Camera
        .onTapGesture { location in
            // Tap-to-focus como iOS Camera
            handleTapToFocus(at: location)
        }
        .captureErrorHandler(
            error: currentError?.asCaptureError,
            onRetry: { clearErrorAndRetry() },
            onCancel: { clearErrorAndCancel() },
            onFallback: onFallbackToManual != nil ? { clearErrorAndFallback() } : nil
        )
        .onAppear {
            initializePreview()
        }
        .accessibilityLabel("Scanner de preços")
        .accessibilityHint("Toque para focar, botão para capturar")
    }
    
    // MARK: - Camera Background (Always Visible)
    
    @ViewBuilder
    private var cameraBackground: some View {
        // Simulação realista de preview da câmera
        ZStack {
            // Background escuro da câmera
            Color.black
            
            // Textura de ruído da câmera
            Rectangle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .gray.opacity(0.1),
                            .black.opacity(0.3)
                        ]),
                        center: .center,
                        startRadius: 100,
                        endRadius: 400
                    )
                )
            
            // Simulação de etiquetas/produtos visíveis na câmera
            VStack {
                Spacer()
                
                // Etiqueta simulada no centro-baixo
                HStack {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CONTINENTE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("Leite Meio Gordo")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        HStack {
                            Text("€1.29")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Spacer()
                            
                            Text("1L")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    Spacer()
                }
                .padding(.bottom, 120)
                
                Spacer()
            }
            
            // Indicador sutil de que é simulação (apenas em desenvolvimento)
            VStack {
                HStack {
                    Spacer()
                    Text("📷 Simulação")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.top, 120)
                        .padding(.trailing, 80)
                }
                Spacer()
            }
        }
    }
    
    // MARK: - State Overlays (Por cima da câmera)
    
    @ViewBuilder
    private var stateOverlays: some View {
        switch scannerState {
        case .idle:
            // Zero overlay - câmera pura
            EmptyView()
            
        case .captured:
            // Apenas flash visual
            capturedFlash
            
        case .processing:
            // Loading minimal
            processingIndicator
            
        case .error:
            // Error minimal
            errorIndicator
        }
    }
    
    @ViewBuilder
    private var capturedFlash: some View {
        // Flash branco súbito - como iOS Camera
        Color.white
            .opacity(scannerState == .captured ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.15), value: scannerState)
    }
    
    @ViewBuilder
    private var processingIndicator: some View {
        VStack {
            Spacer()
            
            // Loading spinner mínimo
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.3), lineWidth: 3)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(.white, lineWidth: 3)
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(scannerState == .processing ? 360 : 0))
                    .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: scannerState)
            }
            .padding(.bottom, 100)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var errorIndicator: some View {
        VStack {
            Spacer()
            
            // Error mínimo - apenas shake + retry
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
                
                if let errorText = scannerState.feedbackText {
                    Text(errorText)
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                Button("↻") {
                    clearErrorAndRetry()
                }
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Circle().fill(.black.opacity(0.6)))
            }
            .padding(.bottom, 100)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var essentialControls: some View {
        VStack {
            // Top: Close button apenas
            HStack {
                Spacer()
                
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(.black.opacity(0.5)))
                }
                .padding(.top, 60)
                .padding(.trailing, 20)
            }
            
            Spacer()
            
            // Bottom: Capture button + flash toggle
            HStack {
                // Flash toggle (esquerda)
                if scannerState == .idle {
                    Button(action: toggleFlash) {
                        Image(systemName: flashEnabled ? "bolt.fill" : "bolt.slash.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(.black.opacity(0.5)))
                    }
                }
                
                Spacer()
                
                // Capture button (centro)
                if scannerState == .idle {
                    Button(action: capturePhoto) {
                        ZStack {
                            Circle()
                                .stroke(.white, lineWidth: 6)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .fill(.white)
                                .frame(width: 66, height: 66)
                        }
                    }
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = pressing
                        }
                    }, perform: {})
                }
                
                Spacer()
                
                // Placeholder para simetria
                if scannerState == .idle {
                    Color.clear
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.bottom, 100)
        }
    }
    

    

    

    

    

    
    // MARK: - Methods
    
    /// Handle tap-to-focus gesture like iOS Camera app
    private func handleTapToFocus(at location: CGPoint) {
        // TODO: Implementar focus real da câmera quando integrar com AVFoundation
        print("🎯 Focus tap at: \(location)")
        
        // Feedback visual sutil (opcional)
        // Pode adicionar animação de círculo de focus no futuro
    }
    
    /// Toggle flash on/off like iOS Camera app
    private func toggleFlash() {
        flashEnabled.toggle()
        print("⚡ Flash toggled: \(flashEnabled ? "ON" : "OFF")")
        
        // TODO: Implementar controle real do flash quando integrar com AVFoundation
    }
    
    private func initializePreview() {
        print("📊 Analytics: \(CaptureMethod.scanner.analyticsName) - preview_started")
        
        scannerState = .idle
        currentError = nil
        
        // Sem scanning automático - apenas preview
        // O usuário controla quando capturar via botão
    }
    
    private func capturePhoto() {
        print("📊 Analytics: \(CaptureMethod.scanner.analyticsName) - capture_attempt")
        
        // Feedback tátil
        // TODO: Adicionar HapticManager.shared.impact(.medium)
        
        // Transição: idle → captured → processing
        scannerState = .captured
        
        // Simular captura da foto
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Iniciar processamento OCR
            processOCR()
        }
    }
    
    private func processOCR() {
        print("📊 Analytics: \(CaptureMethod.scanner.analyticsName) - ocr_started")
        
        scannerState = .processing
        
        // Simular processamento OCR (substituir por VisionKit real)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            simulateOCRResult()
        }
    }
    
    private func handleError(_ error: ScannerError) {
        scannerState = .error(error)
        currentError = error
        onError?(error)
    }
    
    private func handleSuccess(name: String, price: Double?) {
        // Criar ProductData com CaptureMethod.scanner e chamar callback
        let productData = ProductData(
            name: name, 
            price: price ?? 0.0,
            captureMethod: .scanner
        )
        
        print("📊 Analytics: \(CaptureMethod.scanner.analyticsName) - success_callback - \(productData.name)")
        
        // Chamar callback imediatamente com dados completos
        onItemScanned(productData)
    }
    
    // MARK: - Error Recovery Actions
    
    private func clearErrorAndRetry() {
        currentError = nil
        initializePreview()
    }
    
    private func clearErrorAndCancel() {
        currentError = nil
        onCancel()
    }
    
    private func clearErrorAndFallback() {
        currentError = nil
        onFallbackToManual?()
    }
    
    // MARK: - OCR Simulation (substituir por VisionKit real)
    
    private func simulateOCRResult() {
        print("📊 Analytics: \(CaptureMethod.scanner.analyticsName) - ocr_processing")
        
        let errorProbability = Double.random(in: 0...1)
        
        if errorProbability > 0.75 { // 25% chance de erro
            let errors: [ScannerError] = [
                .recognitionFailed,
                .processingTimeout,
                .invalidData,
                .networkUnavailable
            ]
            let randomError = errors.randomElement()!
            print("📊 Analytics: \(CaptureMethod.scanner.analyticsName) - ocr_failed - \(randomError)")
            handleError(randomError)
        } else {
            // Sucesso - produtos portugueses realistas
            let mockProducts = [
                ("Leite Mimosa Meio Gordo 1L", 1.29),
                ("Pão de Forma Bimbo", 0.89), 
                ("Iogurte Natural Danone", 2.49),
                ("Queijo Flamengo Serra da Estrela", 3.99),
                ("Azeite Virgem Extra Gallo", 4.29),
                ("Água Luso 1.5L", 0.65),
                ("Café Delta Torrado", 2.85),
                ("Arroz Cigala Carolino", 1.95),
                ("Bacalhau Ribeira Demolhado", 12.50),
                ("Vinho Tinto Mateus", 3.45),
                ("Massa Milaneza Esparguete", 0.75),
                ("Atum Nuri em Conserva", 1.35),
                ("Açúcar Sidul Branco", 1.15),
                ("Manteiga Mimosa com Sal", 2.25),
                ("Cereais Nestlé Chocapic", 3.85)
            ]
            
            let (name, price) = mockProducts.randomElement()!
            print("📊 Analytics: \(CaptureMethod.scanner.analyticsName) - ocr_success - \(name)")
            handleSuccess(name: name, price: price)
        }
    }
}

// MARK: - Previews

#Preview("Scanner with Manual Capture") {
    ScannerOverlay(
        onItemScanned: { productData in
            print("Capturado: \(productData.name), €\(productData.price)")
        },
        onCancel: {
            print("Cancelado")
        },
        onError: { error in
            print("Erro do scanner: \(error)")
        },
        onFallbackToManual: {
            print("Inserção manual")
        }
    )
    .themeProvider(.preview)
}

#Preview("Scanner Overlay - Idle State") {
    ScannerOverlay(
        onItemScanned: { productData in
            print("Capturado: \(productData.name), €\(productData.price)")
        },
        onCancel: {
            print("Cancelado")
        }
    )
    .themeProvider(.preview)
}

#Preview("Scanner Overlay - Processing State") {
    @Previewable @State var state: ScannerState = .processing
    
    ScannerOverlay(
        onItemScanned: { _ in },
        onCancel: { }
    )
    .themeProvider(.preview)
}

#Preview("Scanner Overlay - Error State") {
    @Previewable @State var state: ScannerState = .error(.recognitionFailed)
    
    ScannerOverlay(
        onItemScanned: { _ in },
        onCancel: { }
    )
    .themeProvider(.darkPreview)
    .preferredColorScheme(.dark)
}
