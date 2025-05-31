import SwiftUI

/// Estados do scanner durante o processo de captura
public enum ScannerState: Sendable, Equatable {
    case idle
    case scanning
    case processing
    case success(String, Double?)
    case error(ScannerError)
    
    /// Mensagens descontraídas mas profissionais em português de Portugal
    public var instructionText: String {
        switch self {
        case .idle: return "Aponte a câmara para a etiqueta 📱"
        case .scanning: return "Um segundo...! 👀"
        case .processing: return "A pensar... quase lá! 🤔"
        case .success: return "Consegui! Produto reconhecido ✅"
        case .error: return "Ops, não consegui. Tente outra vez 🔄"
        }
    }
}

/// Tipos de erro que podem ocorrer durante o scanning
public enum ScannerError: LocalizedError, Sendable, Equatable {
    case cameraUnavailable
    case recognitionFailed
    case processingTimeout
    case invalidData
    
    public var errorDescription: String? {
        switch self {
        case .cameraUnavailable: return "Câmara não disponível 📱"
        case .recognitionFailed: return "Não consegui ler o texto 👀"
        case .processingTimeout: return "Demorou muito... tente de novo ⏰"
        case .invalidData: return "Isto não parece uma etiqueta 🤨"
        }
    }
}

/// Interface de scanner OCR premium com animações e feedback visual
public struct ScannerOverlay: View {
    @Environment(\.themeProvider) private var themeProvider
    
    // MARK: - Properties
    private let onItemScanned: (String, Double?) -> Void
    private let onCancel: () -> Void
    private let onError: ((ScannerError) -> Void)?
    
    // MARK: - State
    @State private var scannerState: ScannerState = .idle
    @State private var scanLineOffset: CGFloat = 0
    @State private var isScanning = false
    @State private var showingRetry = false
    @State private var cornerScale: CGFloat = 1.0
    
    // MARK: - Animation Constants
    private let scanAnimationDuration: Double = 2.0
    private let cornerAnimationDuration: Double = 1.5
    
    // ✅ SwiftUI-Only: GeometryReader em vez de UIScreen
    private func scanFrameSize(geometry: GeometryProxy) -> CGSize {
        // Calcula tamanho baseado na geometry, deixando apenas margens mínimas
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        
        // Margens: 32px nas laterais, espaço para texto (120px topo/fundo)
        let width = screenWidth - 64  // 32px de cada lado
        let height = screenHeight - 280  // 120px topo + 120px fundo + safe areas
        
        return CGSize(width: width, height: max(height, 300)) // Mínimo 300px altura
    }
    
    public init(
        onItemScanned: @escaping (String, Double?) -> Void,
        onCancel: @escaping () -> Void,
        onError: ((ScannerError) -> Void)? = nil
    ) {
        self.onItemScanned = onItemScanned
        self.onCancel = onCancel
        self.onError = onError
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background escurecido
                overlayBackground
                
                VStack(spacing: 0) {
                    // Instruções compactas no topo
                    instructionView
                        .padding(.top, themeProvider.theme.spacing.lg)
                    
                    // Frame de captura expandido - máximo espaço
                    Spacer()
                    
                    scanningFrame(geometry: geometry)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Spacer()
                    
                    // Feedback de estado compacto
                    stateIndicator
                        .padding(.bottom, themeProvider.theme.spacing.lg)
                }
                
                // Botão fechar - canto superior direito
                cancelButton
            }
        }
        .onAppear {
            startScanning()
        }
        .accessibilityLabel("Scanner de preços")
        .accessibilityHint("Área expandida para melhor enquadramento")
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var overlayBackground: some View {
        Color.black
            .opacity(0.7)
            .ignoresSafeArea()
            .onTapGesture {
                onCancel()
            }
    }
    
    @ViewBuilder
    private var instructionView: some View {
        Text(scannerState.instructionText)
            .font(themeProvider.theme.typography.bodyLarge)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .animation(themeProvider.theme.animation.spring, value: scannerState)
            .padding(.horizontal, themeProvider.theme.spacing.lg)
            
        // Botão retry inline quando erro
        if case .error = scannerState {
            ActionButton(
                "Tentar novamente",
                systemImage: "arrow.clockwise",
                type: .secondary
            ) {
                retryScanning()
            }
            .frame(maxWidth: 200)
            .padding(.top, themeProvider.theme.spacing.sm)
        }
    }
    
    @ViewBuilder
    private func scanningFrame(geometry: GeometryProxy) -> some View {
        let frameSize = scanFrameSize(geometry: geometry)
        
        ZStack {
            // Frame principal expandido
            RoundedRectangle(cornerRadius: 24) // Cantos mais arredondados
                .stroke(frameColor, lineWidth: 3) // Linha mais espessa
                .frame(width: frameSize.width, height: frameSize.height)
                .scaleEffect(cornerScale)
                .animation(
                    Animation.easeInOut(duration: cornerAnimationDuration)
                        .repeatForever(autoreverses: true),
                    value: cornerScale
                )
            
            // Cantos destacados (ocultos por enquanto)
            frameCorners(frameSize: frameSize)
            
            // Linha de scan expandida
            if isScanning {
                scanLine(frameSize: frameSize)
            }
            
            // Overlay de sucesso/erro
            if case .success = scannerState {
                successOverlay(frameSize: frameSize)
            } else if case .error = scannerState {
                errorOverlay(frameSize: frameSize)
            }
        }
        .padding(.horizontal, themeProvider.theme.spacing.lg)
    }
    
    @ViewBuilder
    private func frameCorners(frameSize: CGSize) -> some View {
        let cornerSize: CGFloat = 0
        let cornerThickness: CGFloat = 0
        
        ZStack {
            // Cantos ocultos (size = 0, thickness = 0)
            Path { path in
                path.move(to: CGPoint(x: frameSize.width/2 - 8 - cornerSize, y: -frameSize.height/2 + 8))
                path.addLine(to: CGPoint(x: frameSize.width/2 - 8, y: -frameSize.height/2 + 8))
                path.addLine(to: CGPoint(x: frameSize.width/2 - 8, y: -frameSize.height/2 + 8 + cornerSize))
            }
            .stroke(Color.white, lineWidth: cornerThickness)
        }
    }
    
    @ViewBuilder
    private func scanLine(frameSize: CGSize) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, .white, .white, .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: frameSize.width - 64, height: 3) // Linha mais espessa
            .offset(y: scanLineOffset)
            .animation(
                Animation.linear(duration: scanAnimationDuration)
                    .repeatForever(autoreverses: true),
                value: scanLineOffset
            )
    }
    
    @ViewBuilder
    private func successOverlay(frameSize: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.green.opacity(0.2))
                .frame(width: frameSize.width, height: frameSize.height)
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60)) // Ícone maior
                .foregroundColor(.green)
                .scaleEffect(1.2)
                .animation(themeProvider.theme.animation.spring, value: scannerState)
        }
    }
    
    @ViewBuilder
    private func errorOverlay(frameSize: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.red.opacity(0.2))
                .frame(width: frameSize.width, height: frameSize.height)
            
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 60)) // Ícone maior
                .foregroundColor(.red)
                .scaleEffect(1.2)
                .animation(themeProvider.theme.animation.spring, value: scannerState)
        }
    }
    
    @ViewBuilder
    private var stateIndicator: some View {
        Group {
            switch scannerState {
            case .processing:
                HStack(spacing: themeProvider.theme.spacing.sm) {
                    ProgressView()
                        .scaleEffect(1.0) // Tamanho normal
                        .tint(.white)
                    
                    Text("Só um momento...")
                        .font(themeProvider.theme.typography.bodyLarge)
                        .foregroundColor(.white)
                }
                
            case .scanning:
                HStack(spacing: themeProvider.theme.spacing.sm) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10) // Indicador maior
                        .scaleEffect(isScanning ? 1.5 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true),
                            value: isScanning
                        )
                    
                    Text("A analisar...")
                        .font(themeProvider.theme.typography.bodyLarge)
                        .foregroundColor(.white)
                }
                
            default:
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    private var cancelButton: some View {
        VStack {
            HStack {
                Spacer()
                
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.title2) // Botão maior
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44) // Área de toque maior
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.6))
                        )
                }
                .accessibilityLabel("Fechar scanner")
            }
            .padding(.top, themeProvider.theme.spacing.lg)
            .padding(.trailing, themeProvider.theme.spacing.lg)
            
            Spacer()
        }
    }
    
    // MARK: - Computed Properties
    
    private var frameColor: Color {
        switch scannerState {
        case .success: return .green
        case .error: return .red
        case .scanning: return themeProvider.theme.colors.cadaEuroAccent
        default: return .white
        }
    }
    
    // MARK: - Methods
    
    private func startScanning() {
        scannerState = .scanning
        isScanning = true
        cornerScale = 1.02 // Animação mais sutil
        
        // Inicia animação da linha de scan - amplitude será calculada dinamicamente
        scanLineOffset = -150 // Valor fixo temporário, será ajustado com geometria
        
        // Simula processo de scanning (será substituído por VisionKit real)
        simulateScanning()
    }
    
    private func retryScanning() {
        // ✅ SwiftUI-Only: Sem UIImpactFeedbackGenerator
        // Feedback háptico será adicionado via SensoryFeedback quando disponível
        
        startScanning()
    }
    
    // MARK: - Simulation (substituir por VisionKit real)
    
    private func simulateScanning() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            scannerState = .processing
            isScanning = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // Simula sucesso 80% das vezes
                if Bool.random() && Double.random(in: 0...1) > 0.2 {
                    let mockProducts = [
                        ("Leite Mimosa", 1.29),
                        ("Pão de Forma", 0.89),
                        ("Iogurte Natural", 2.49),
                        ("Queijo Flamengo", 3.99),
                        ("Azeite Virgem", 4.29)
                    ]
                    let product = mockProducts.randomElement()!
                    scannerState = .success(product.0, product.1)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        onItemScanned(product.0, product.1)
                    }
                } else {
                    let error = ScannerError.recognitionFailed
                    scannerState = .error(error)
                    onError?(error)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Scanner Overlay - Idle") {
    ScannerOverlay(
        onItemScanned: { name, price in
            print("Scanned: \(name), €\(price ?? 0)")
        },
        onCancel: {
            print("Cancelled")
        }
    )
    .themeProvider(.preview)
}

#Preview("Scanner Overlay - Processing") {
    @Previewable @State var state: ScannerState = .processing
    
    ScannerOverlay(
        onItemScanned: { _, _ in },
        onCancel: { }
    )
    .themeProvider(.preview)
}

#Preview("Scanner Overlay - Error") {
    @Previewable @State var state: ScannerState = .error(.recognitionFailed)
    
    ScannerOverlay(
        onItemScanned: { _, _ in },
        onCancel: { }
    )
    .themeProvider(.darkPreview)
    .preferredColorScheme(.dark)
}
