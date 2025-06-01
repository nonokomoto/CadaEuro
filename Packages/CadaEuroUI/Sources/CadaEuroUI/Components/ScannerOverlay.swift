import SwiftUI
import CadaEuroKit  

/// Estados simplificados do scanner - apenas essenciais
public enum ScannerState: Sendable, Equatable {
    case idle
    case processing
    case error(ScannerError)
    
    /// Mensagem única durante processamento - sem detalhes técnicos
    public var instructionText: String {
        switch self {
        case .idle: return "Aponte a câmara para a etiqueta"
        case .processing: return "Um segundo... 🤔"
        case .error: return "Ups, não consegui. Tente outra vez"
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
            
            // Overlays por cima da câmera conforme estado
            stateOverlays
            
            // Botão cancelar sempre visível no canto superior direito
            cancelButton
        }
        .ignoresSafeArea() // Tela cheia como Apple Notes scanner
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
            startScanning()
        }
        .accessibilityLabel("Scanner de preços")
        .accessibilityHint("Câmara em ecrã completo para captura")
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
            // Apenas overlay sutil com frame/instruções
            idleOverlay
            
        case .processing:
            // Loading overlay semi-transparente
            processingOverlay
            
        case .error:
            // Error popup centrado
            errorOverlay
        }
    }
    
    @ViewBuilder
    private var idleOverlay: some View {
        VStack(spacing: 0) {
            // Área superior com instruções
            VStack(spacing: themeProvider.theme.spacing.md) {
                Text(scannerState.instructionText)
                    .font(themeProvider.theme.typography.bodySmall)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Mantenha o telemóvel estável e a etiqueta dentro do quadro")
                    .font(themeProvider.theme.typography.bodyMedium)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.horizontal, themeProvider.theme.spacing.xl)
            .padding(.top, 120) // Safe area + espaço para botão cancelar
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .black.opacity(0.7),
                        .black.opacity(0.3),
                        .clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            Spacer()
            
            // Frame de captura no centro
            scanningFrame
            
            Spacer()
            
            // Área inferior com dicas
            VStack(spacing: themeProvider.theme.spacing.sm) {
                HStack(spacing: themeProvider.theme.spacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                        .foregroundColor(.yellow.opacity(0.8))
                    
                    Text("Boa iluminação melhora a precisão")
                        .font(themeProvider.theme.typography.bodySmall)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                HStack(spacing: themeProvider.theme.spacing.sm) {
                    Image(systemName: "target")
                        .font(.caption)
                        .foregroundColor(.blue.opacity(0.8))
                    
                    Text("Foque no preço e nome do produto")
                        .font(themeProvider.theme.typography.bodySmall)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, themeProvider.theme.spacing.xl)
            .padding(.bottom, 120) // Safe area + espaço
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .black.opacity(0.3),
                        .black.opacity(0.7)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    @ViewBuilder
    private var processingOverlay: some View {
        // Overlay escuro semi-transparente com loading customizado
        ZStack {
            Color.black.opacity(0.85)
            
            VStack(spacing: themeProvider.theme.spacing.xl) {
                // Loading indicator customizado
                ZStack {
                    Circle()
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    themeProvider.theme.colors.cadaEuroAccent,
                                    themeProvider.theme.colors.cadaEuroAccent.opacity(0.3)
                                ]),
                                center: .center
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(scannerState == .processing ? 360 : 0))
                        .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: scannerState)
                    
                    Image(systemName: "viewfinder")
                        .font(.title2)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
                }
                
                VStack(spacing: themeProvider.theme.spacing.md) {
                    Text(scannerState.instructionText)
                        .font(themeProvider.theme.typography.bodySmall)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                }
                
                // Barra de progresso simulada
                ProgressView(value: 0.7)
                    .progressViewStyle(LinearProgressViewStyle(tint: themeProvider.theme.colors.cadaEuroAccent))
                    .frame(width: 200)
            }
            .padding(themeProvider.theme.spacing.xl)
        }
    }
    
    @ViewBuilder
    private var errorOverlay: some View {
        // Background escuro com blur
        ZStack {
            Color.black.opacity(0.6)
                .blur(radius: 1)
            
            VStack {
                Spacer()
                
                // Card de erro com Material Design
                VStack(spacing: themeProvider.theme.spacing.xl) {
                    // Ícone de erro animado
                    ZStack {
                        Circle()
                            .fill(themeProvider.theme.colors.cadaEuroError.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(themeProvider.theme.colors.cadaEuroError)
                    }
                    
                    VStack(spacing: themeProvider.theme.spacing.md) {
                        Text("Ops! Algo correu mal")
                            .font(themeProvider.theme.typography.bodySmall)
                            .fontWeight(.semibold)
                            .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text(scannerState.instructionText)
                            .font(themeProvider.theme.typography.bodyMedium)
                            .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                    }
                    
                    // Botões de ação
                    VStack(spacing: themeProvider.theme.spacing.md) {
                        ActionButton(
                            "Tentar Novamente",
                            systemImage: "arrow.clockwise",
                            type: .primary
                        ) {
                            clearErrorAndRetry()
                        }
                        
                        if onFallbackToManual != nil {
                            ActionButton(
                                "Inserção Manual",
                                systemImage: "keyboard",
                                type: .secondary
                            ) {
                                clearErrorAndFallback()
                            }
                        }
                        
                        Button("Cancelar") {
                            clearErrorAndCancel()
                        }
                        .font(themeProvider.theme.typography.bodyMedium)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                    }
                }
                .padding(themeProvider.theme.spacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: themeProvider.theme.border.cardRadius)
                        .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
                        .shadow(
                            color: .black.opacity(0.3),
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                )
                .padding(themeProvider.theme.spacing.xl)
                
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var scanningFrame: some View {
        ZStack {
            // Frame principal com animação de pulse
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            themeProvider.theme.colors.cadaEuroAccent,
                            themeProvider.theme.colors.cadaEuroAccent.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 320, height: 200)
                .scaleEffect(scannerState == .idle ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: scannerState)
            
            // Linha de scan animada (movimenta verticalmente)
            if scannerState == .idle {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .clear,
                                themeProvider.theme.colors.cadaEuroAccent.opacity(0.8),
                                themeProvider.theme.colors.cadaEuroAccent,
                                themeProvider.theme.colors.cadaEuroAccent.opacity(0.8),
                                .clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 300, height: 2)
                    .offset(y: scanAnimationOffset)
                    .animation(.linear(duration: 2.0).repeatForever(autoreverses: true), value: scanAnimationOffset)
                    .onAppear {
                        scanAnimationOffset = -80
                        withAnimation {
                            scanAnimationOffset = 80
                        }
                    }
            }
            
            // Cantos decorativos melhorados
            VStack {
                HStack {
                    enhancedCornerIndicator
                    Spacer()
                    enhancedCornerIndicator.rotationEffect(.degrees(90))
                }
                Spacer()
                HStack {
                    enhancedCornerIndicator.rotationEffect(.degrees(-90))
                    Spacer()
                    enhancedCornerIndicator.rotationEffect(.degrees(180))
                }
            }
            .frame(width: 320, height: 200)
            .padding(12)
            
            // Texto central sutil
            if scannerState == .idle {
                Text("Etiqueta aqui")
                    .font(themeProvider.theme.typography.bodySmall)
                    .foregroundColor(.white.opacity(0.5))
                    .background(
                        Capsule()
                            .fill(.black.opacity(0.3))
                            .frame(height: 24)
                    )
                    .padding(.horizontal, 12)
            }
        }
    }
    
    // Estado para animação da linha de scan
    @State private var scanAnimationOffset: CGFloat = -80
    
    @ViewBuilder
    private var enhancedCornerIndicator: some View {
        ZStack {
            // Canto exterior
            VStack(spacing: 0) {
                Rectangle()
                    .fill(themeProvider.theme.colors.cadaEuroAccent)
                    .frame(width: 25, height: 4)
                Rectangle()
                    .fill(themeProvider.theme.colors.cadaEuroAccent)
                    .frame(width: 4, height: 25)
            }
            
            // Brilho interno
            VStack(spacing: 0) {
                Rectangle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 25, height: 2)
                Rectangle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 2, height: 25)
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
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.black.opacity(0.6))
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                .accessibilityLabel("Fechar scanner")
            }
            .padding(.top, 60) // Safe area + margin
            .padding(.trailing, themeProvider.theme.spacing.lg)
            
            Spacer()
        }
    }
    
    // MARK: - Computed Properties
    
    private var frameColor: Color {
        return themeProvider.theme.colors.cadaEuroTextPrimary
    }
    
    // MARK: - Methods
    
    private func startScanning() {
        print("📊 Analytics: \(CaptureMethod.scanner.analyticsName) - scan_attempt")
        
        scannerState = .idle
        currentError = nil
        
        // Simular fluxo completo: idle → processing → success/error
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            simulateScanning()
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
        startScanning()
    }
    
    private func clearErrorAndCancel() {
        currentError = nil
        onCancel()
    }
    
    private func clearErrorAndFallback() {
        currentError = nil
        onFallbackToManual?()
    }
    
    // MARK: - Simulation (substituir por VisionKit real)
    
    private func simulateScanning() {
        print("📊 Analytics: \(CaptureMethod.scanner.analyticsName) - processing_started")
        
        // Entrar em modo processing (tela escura)
        scannerState = .processing
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let errorProbability = Double.random(in: 0...1)
            
            if errorProbability > 0.7 { // 30% chance de erro
                let errors: [ScannerError] = [
                    .recognitionFailed,
                    .processingTimeout,
                    .invalidData,
                    .networkUnavailable
                ]
                let randomError = errors.randomElement()!
                print("📊 Analytics: \(CaptureMethod.scanner.analyticsName) - scan_failed - \(randomError)")
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
                print("📊 Analytics: \(CaptureMethod.scanner.analyticsName) - scan_success - \(name)")
                handleSuccess(name: name, price: price)
            }
        }
    }
}

// MARK: - Previews

#Preview("Scanner with Error Recovery") {
    ScannerOverlay(
        onItemScanned: { productData in
            print("Digitalizado: \(productData.name), €\(productData.price)")
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

#Preview("Scanner Overlay - Idle") {
    ScannerOverlay(
        onItemScanned: { productData in
            print("Digitalizado: \(productData.name), €\(productData.price)")
        },
        onCancel: {
            print("Cancelado")
        }
    )
    .themeProvider(.preview)
}

#Preview("Scanner Overlay - Processing") {
    @Previewable @State var state: ScannerState = .processing
    
    ScannerOverlay(
        onItemScanned: { _ in },
        onCancel: { }
    )
    .themeProvider(.preview)
}

#Preview("Scanner Overlay - Error") {
    @Previewable @State var state: ScannerState = .error(.recognitionFailed)
    
    ScannerOverlay(
        onItemScanned: { _ in },
        onCancel: { }
    )
    .themeProvider(.darkPreview)
    .preferredColorScheme(.dark)
}
