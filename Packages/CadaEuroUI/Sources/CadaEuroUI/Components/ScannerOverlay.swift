import SwiftUI

/// Componente de overlay para o scanner OCR
/// Exibe um frame de reconhecimento com animação de linha de scan e indicadores de canto
public struct ScannerOverlay: View {
    @Environment(\.themeProvider) private var themeProvider
    
    /// Largura do frame de reconhecimento
    private let frameWidth: CGFloat
    
    /// Altura do frame de reconhecimento
    private let frameHeight: CGFloat
    
    /// Mensagem de instrução
    private let instructionMessage: String
    
    /// Estado de animação da linha de scan
    @State private var scanLinePosition: CGFloat = 0
    
    /// Estado de animação do pulso dos cantos
    @State private var cornerPulse: Bool = false
    
    /// Inicializador do componente
    /// - Parameters:
    ///   - frameWidth: Largura do frame de reconhecimento
    ///   - frameHeight: Altura do frame de reconhecimento
    ///   - instructionMessage: Mensagem de instrução (padrão: "Aponte para a etiqueta")
    public init(
        frameWidth: CGFloat,
        frameHeight: CGFloat,
        instructionMessage: String = "Aponte para a etiqueta"
    ) {
        self.frameWidth = frameWidth
        self.frameHeight = frameHeight
        self.instructionMessage = instructionMessage
    }
    
    public var body: some View {
        ZStack {
            // Fundo semi-transparente
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false)
            
            // Área de recorte (transparente)
            Rectangle()
                .frame(width: frameWidth, height: frameHeight)
                .blendMode(.destinationOut)
            
            // Frame de reconhecimento
            scanFrame
            
            // Linha de scan animada
            scanLine
            
            // Mensagem de instrução
            instructionView
        }
        .compositingGroup()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Scanner de preços")
        .accessibilityHint("Mantenha a câmara apontada para a etiqueta de preço")
        .onAppear {
            startAnimations()
        }
    }
    
    /// Frame de reconhecimento com indicadores de canto
    private var scanFrame: some View {
        ZStack {
            // Borda do frame
            RoundedRectangle(cornerRadius: themeProvider.theme.border.smallButtonRadius)
                .strokeBorder(themeProvider.theme.colors.cadaEuroAccent, lineWidth: themeProvider.theme.border.emphasizedBorderWidth)
                .frame(width: frameWidth, height: frameHeight)
            
            // Indicadores de canto
            VStack {
                HStack {
                    cornerIndicator(alignment: .topLeading)
                    Spacer()
                    cornerIndicator(alignment: .topTrailing)
                }
                
                Spacer()
                
                HStack {
                    cornerIndicator(alignment: .bottomLeading)
                    Spacer()
                    cornerIndicator(alignment: .bottomTrailing)
                }
            }
            .frame(width: frameWidth, height: frameHeight)
        }
    }
    
    /// Linha de scan animada
    private var scanLine: some View {
        Rectangle()
            .fill(themeProvider.theme.colors.cadaEuroAccent.opacity(0.7))
            .frame(width: frameWidth - 8, height: 2)
            .offset(y: scanLinePosition)
            .animation(.easeInOut(duration: themeProvider.theme.animation.longDuration * 4).repeatForever(autoreverses: true), value: scanLinePosition)
    }
    
    /// Mensagem de instrução
    private var instructionView: some View {
        Text(instructionMessage)
            .font(themeProvider.theme.typography.bodyLarge)
            .foregroundColor(.white)
            .padding(.horizontal, themeProvider.theme.spacing.sm)
            .padding(.vertical, themeProvider.theme.spacing.xs)
            .background(Color.black.opacity(0.7))
            .cornerRadius(themeProvider.theme.border.smallButtonRadius)
            .offset(y: frameHeight / 2 + 40)
    }
    
    /// Indicador de canto
    /// - Parameter alignment: Alinhamento do canto (topLeading, topTrailing, bottomLeading, bottomTrailing)
    private func cornerIndicator(alignment: Alignment) -> some View {
        ZStack {
            // Linha horizontal
            Rectangle()
                .fill(themeProvider.theme.colors.cadaEuroAccent)
                .frame(width: 20, height: 3)
                .scaleEffect(cornerPulse ? 1.1 : 1.0)
            
            // Linha vertical
            Rectangle()
                .fill(themeProvider.theme.colors.cadaEuroAccent)
                .frame(width: 3, height: 20)
                .scaleEffect(cornerPulse ? 1.1 : 1.0)
        }
        .rotationEffect(rotationForAlignment(alignment))
        .frame(width: 20, height: 20)
        .animation(.easeInOut(duration: themeProvider.theme.animation.longDuration * 3).repeatForever(autoreverses: true), value: cornerPulse)
    }
    
    /// Rotação para o alinhamento do canto
    /// - Parameter alignment: Alinhamento do canto
    /// - Returns: Ângulo de rotação
    private func rotationForAlignment(_ alignment: Alignment) -> Angle {
        switch alignment {
        case .topLeading:
            return .degrees(0)
        case .topTrailing:
            return .degrees(90)
        case .bottomTrailing:
            return .degrees(180)
        case .bottomLeading:
            return .degrees(270)
        default:
            return .degrees(0)
        }
    }
    
    /// Inicia as animações
    private func startAnimations() {
        // Animar linha de scan
        withAnimation {
            scanLinePosition = frameHeight / 2 - 50
        }
        
        // Animar pulso dos cantos
        withAnimation {
            cornerPulse = true
        }
    }
}

#Preview {
    ZStack {
        // Simulação de fundo de câmara
        Color.gray.opacity(0.8)
            .edgesIgnoringSafeArea(.all)
        
        ScannerOverlay(
            frameWidth: 280,
            frameHeight: 180,
            instructionMessage: "Aponte para o preço"
        )
    }
    .withThemeProvider(ThemeProvider())
}
