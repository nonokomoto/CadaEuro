import SwiftUI
import CadaEuroKit

/// Método de captura do item
public enum CaptureMethod {
    case scanner
    case voice
    case manual
    
    /// Retorna o ícone correspondente ao método de captura
    var icon: String {
        switch self {
        case .scanner: return "camera.fill"
        case .voice: return "mic.fill"
        case .manual: return "keyboard"
        }
    }
    
    /// Retorna a descrição do método de captura
    var description: String {
        switch self {
        case .scanner: return "capturado por scanner"
        case .voice: return "capturado por voz"
        case .manual: return "adicionado manualmente"
        }
    }
}

/// Componente que exibe um item da lista de compras
/// Permite visualizar o nome do produto, preço e suporta gestos para ações
public struct ItemCard: View {
    @Environment(\.themeProvider) private var themeProvider
    
    /// Nome do produto
    private let name: String
    
    /// Preço do produto
    private let price: Double
    
    /// Quantidade do produto
    private let quantity: Int
    
    /// Método de captura do item
    private let captureMethod: CaptureMethod
    
    /// Ação executada ao deslizar para apagar
    private let onDelete: () -> Void
    
    /// Ação executada ao tocar no item
    private let onTap: () -> Void
    
    /// Estado de deslize
    @State private var offset: CGFloat = 0
    
    /// Estado de animação
    @State private var isPressed: Bool = false
    
    /// Inicializador do componente
    /// - Parameters:
    ///   - name: Nome do produto
    ///   - price: Preço do produto
    ///   - quantity: Quantidade do produto (padrão: 1)
    ///   - captureMethod: Método de captura do item (padrão: .manual)
    ///   - onDelete: Ação executada ao deslizar para apagar
    ///   - onTap: Ação executada ao tocar no item
    public init(
        name: String,
        price: Double,
        quantity: Int = 1,
        captureMethod: CaptureMethod = .manual,
        onDelete: @escaping () -> Void,
        onTap: @escaping () -> Void
    ) {
        self.name = name
        self.price = price
        self.quantity = quantity
        self.captureMethod = captureMethod
        self.onDelete = onDelete
        self.onTap = onTap
    }
    
    public var body: some View {
        ZStack {
            // Background para o botão de apagar
            deleteButton
            
            // Card principal
            itemContent
                .offset(x: offset, y: 0)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Limita o deslize apenas para a esquerda e até -80
                            if value.translation.width < 0 {
                                self.offset = max(value.translation.width, -80)
                            }
                        }
                        .onEnded { value in
                            // Se deslizou mais de 50pt, mostra o botão de apagar
                            if value.translation.width < -50 {
                                withAnimation {
                                    self.offset = -80
                                }
                            } else {
                                // Caso contrário, volta à posição original
                                withAnimation {
                                    self.offset = 0
                                }
                            }
                        }
                )
        }
        .frame(height: 60)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name), \(quantity > 1 ? "\(quantity) unidades, " : "")\(String(format: "%.2f", price)) euros, \(captureMethod.description)")
        .accessibilityHint("Deslize para a esquerda para apagar")
    }
    
    /// Conteúdo principal do item
    private var itemContent: some View {
        HStack(spacing: 12) {
            // Emoji contextual baseado no nome do produto
            Text(generateEmoji(for: name))
                .font(.system(size: 24))
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(themeProvider.theme.typography.bodyLarge)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                
                if quantity > 1 {
                    Text("\(quantity)x")
                        .font(themeProvider.theme.typography.caption)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                }
            }
            
            Spacer()
            
            // Preço
            Text("€\(String(format: "%.2f", price))")
                .font(themeProvider.theme.typography.bodyLarge)
                .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(themeProvider.theme.colors.cadaEuroComponentBackground)
        .cornerRadius(16)
        .contentShape(Rectangle())
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .onTapGesture {
            hapticFeedback(.light)
            withAnimation {
                isPressed = true
            }
            
            // Reseta a animação após um breve período
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation {
                    isPressed = false
                }
                onTap()
            }
        }
    }
    
    /// Botão de apagar
    private var deleteButton: some View {
        HStack {
            Spacer()
            
            Button(action: {
                hapticFeedback(.medium)
                withAnimation {
                    self.offset = 0
                }
                onDelete()
            }) {
                Image(systemName: "trash")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 80, height: 60)
                    .background(Color.red)
                    .cornerRadius(16)
            }
        }
        .padding(.trailing, themeProvider.theme.spacing.xs)
    }
    
    /// Gera um emoji contextual baseado no nome do produto
    private func generateEmoji(for productName: String) -> String {
        let lowercaseName = productName.lowercased()
        
        // Categorias de produtos comuns
        if lowercaseName.contains("leite") { return "🥛" }
        if lowercaseName.contains("pão") || lowercaseName.contains("pao") { return "🍞" }
        if lowercaseName.contains("maçã") || lowercaseName.contains("maca") { return "🍎" }
        if lowercaseName.contains("banana") { return "🍌" }
        if lowercaseName.contains("ovo") { return "🥚" }
        if lowercaseName.contains("queijo") { return "🧀" }
        if lowercaseName.contains("carne") { return "🥩" }
        if lowercaseName.contains("frango") { return "🍗" }
        if lowercaseName.contains("peixe") { return "🐟" }
        if lowercaseName.contains("arroz") { return "🍚" }
        if lowercaseName.contains("massa") || lowercaseName.contains("esparguete") { return "🍝" }
        if lowercaseName.contains("batata") { return "🥔" }
        if lowercaseName.contains("cenoura") { return "🥕" }
        if lowercaseName.contains("tomate") { return "🍅" }
        if lowercaseName.contains("alface") || lowercaseName.contains("salada") { return "🥬" }
        if lowercaseName.contains("água") || lowercaseName.contains("agua") { return "💧" }
        if lowercaseName.contains("sumo") || lowercaseName.contains("bebida") { return "🧃" }
        if lowercaseName.contains("vinho") { return "🍷" }
        if lowercaseName.contains("cerveja") { return "🍺" }
        if lowercaseName.contains("café") || lowercaseName.contains("cafe") { return "☕" }
        if lowercaseName.contains("chocolate") { return "🍫" }
        if lowercaseName.contains("bolacha") || lowercaseName.contains("biscoito") { return "🍪" }
        
        // Emoji padrão para outros produtos
        return "🛒"
    }
    
    /// Fornece feedback háptico
    private func hapticFeedback(_ type: HapticManager.FeedbackType) {
        HapticManager.shared.feedback(type)
    }
}

#Preview {
    VStack(spacing: 10) {
        ItemCard(
            name: "Maçãs Golden",
            price: 2.49,
            quantity: 1,
            captureMethod: .scanner,
            onDelete: {},
            onTap: {}
        )
        
        ItemCard(
            name: "Leite Meio-Gordo",
            price: 0.99,
            quantity: 2,
            captureMethod: .voice,
            onDelete: {},
            onTap: {}
        )
        
        ItemCard(
            name: "Pão de Forma",
            price: 1.79,
            quantity: 1,
            captureMethod: .manual,
            onDelete: {},
            onTap: {}
        )
    }
    .padding()
    .background(themeProvider.theme.colors.cadaEuroBackground)
    .withThemeProvider(ThemeProvider())
}