import SwiftUI
import CadaEuroKit

/// Dados do produto para o ItemCard
public struct ShoppingItem: Identifiable, Hashable, Sendable {
    public let id = UUID()
    public let name: String
    public let price: Double
    public let quantity: Int
    public let captureMethod: CaptureMethod
    public let dateAdded: Date
    
    public init(
        name: String,
        price: Double,
        quantity: Int = 1,
        captureMethod: CaptureMethod = .manual,
        dateAdded: Date = Date()
    ) {
        self.name = name
        self.price = price
        self.quantity = quantity
        self.captureMethod = captureMethod
        self.dateAdded = dateAdded
    }
    
    /// Preço total (preço × quantidade)
    public var totalPrice: Double {
        price * Double(quantity)
    }
    
    /// Formatação do preço unitário usando Validators
    public var formattedPrice: String {
        // ✅ USAR VALIDATORS: Validação antes da formatação
        let validation = ProductValidator.validatePrice(price, captureMethod: captureMethod)
        
        if validation.isValid {
            return price.asItemCardPrice  // ✅ DoubleExtensions para formatação básica
        } else {
            // Fallback seguro para preços inválidos
            return 0.0.asItemCardPrice
        }
    }
    
    /// Formatação do preço total usando Validators
    public var formattedTotalPrice: String {
        // ✅ USAR VALIDATORS: Validação completa do produto
        let validation = ProductValidator.validate(
            name: name,
            price: price,
            quantity: quantity,
            captureMethod: captureMethod
        )
        
        if validation.isValid {
            return totalPrice.asItemCardPrice  // ✅ DoubleExtensions para formatação
        } else {
            // ✅ USAR VALIDATORS: Warnings não impedem exibição
            if !validation.warnings.isEmpty {
                print("⚠️ ItemCard warnings: \(validation.warnings.joined(separator: ", "))")
            }
            
            // Exibir mesmo com warnings (não são críticos)
            return totalPrice.asItemCardPrice
        }
    }
}

/// Estado do ItemCard para interações
public enum ItemCardState: Sendable {
    case normal
    case editing
    case deleting
    case selected
}

/// Card premium para exibir produtos na lista de compras
public struct ItemCard: View {
    @Environment(\.themeProvider) private var themeProvider
    
    private let item: ShoppingItem
    private let state: ItemCardState
    private let onDelete: (() -> Void)?
    private let onQuantityChange: ((Int) -> Void)?
    
    @State private var isPressed = false
    @State private var dragOffset: CGSize = .zero
    @State private var showingDeleteAction = false
    @State private var isScrollEnabled = true
    
    public init(
        item: ShoppingItem,
        state: ItemCardState = .normal,
        onDelete: (() -> Void)? = nil,
        onQuantityChange: ((Int) -> Void)? = nil
    ) {
        self.item = item
        self.state = state
        self.onDelete = onDelete
        self.onQuantityChange = onQuantityChange
    }
    
    public var body: some View {
        HStack(spacing: themeProvider.theme.spacing.lg) {
            // Ícone do produto
            productIcon
            
            // Nome do produto
            Text(item.name)
                .font(themeProvider.theme.typography.bodyLarge)
                .foregroundColor(textColor)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            // Valor total - ✅ USAR DoubleExtensions
            Text(item.totalPrice.asItemCardPrice)
                .font(themeProvider.theme.typography.bodyLarge)
                .fontWeight(.semibold)
                .foregroundColor(priceColor)
            
            // Ação de eliminar (se a mostrar)
            if showingDeleteAction {
                deleteButton
            }
        }
        .padding(themeProvider.theme.spacing.lg)
        .background(cardBackground)
        .cornerRadius(themeProvider.theme.border.cardRadius)
        .overlay(
            RoundedRectangle(cornerRadius: themeProvider.theme.border.cardRadius)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .scaleEffect(scaleEffect)
        .offset(dragOffset)
        // .shadow(
        //     color: shadowColor,
        //     radius: shadowRadius,
        //     x: 0,
        //     y: shadowOffset
        // )
        .simultaneousGesture(swipeGesture)
        .onLongPressGesture(minimumDuration: 0) { pressing in
            withAnimation(themeProvider.theme.animation.quick) {
                isPressed = pressing
            }
        } perform: {}
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(accessibilityTraits)
        // ✅ Adicionar suporte a ajuste para VoiceOver
        .accessibilityAdjustableAction { direction in
            guard let onQuantityChange = onQuantityChange else { return }
            
            switch direction {
            case .increment:
                onQuantityChange(item.quantity + 1)
            case .decrement:
                if item.quantity > 1 {
                    onQuantityChange(item.quantity - 1)
                }
            @unknown default:
                break
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var productIcon: some View {
        ZStack {
            Circle()
                .fill(iconBackgroundColor)
                .frame(width: 40, height: 40)
            
            Image(systemName: productSystemImage)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
        }
    }
    
    @ViewBuilder
    private var deleteButton: some View {
        Button(action: { onDelete?() }) {
            Image(systemName: "trash.fill")
                .font(themeProvider.theme.typography.bodyMedium)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(themeProvider.theme.colors.cadaEuroError)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        // Usar uma transição mais simples para evitar problemas de animação
        .transition(.opacity)
    }
    
    // MARK: - Computed Properties
    
    private var productSystemImage: String {
        // Retorna ícone baseado no nome do produto
        let name = item.name.lowercased()
        
        if name.contains("leite") || name.contains("iogurte") {
            return "drop.fill"
        } else if name.contains("pão") || name.contains("cereais") {
            return "leaf.fill"
        } else if name.contains("maçã") || name.contains("fruta") {
            return "apple.logo"
        } else if name.contains("carne") || name.contains("peixe") {
            return "fish.fill"
        } else {
            return "basket.fill"
        }
    }
    
    private var iconBackgroundColor: Color {
        themeProvider.theme.colors.cadaEuroAccent.opacity(0.1)
    }
    
    private var cardBackground: Color {
        switch state {
        case .normal:
            return themeProvider.theme.colors.cadaEuroComponentBackground
        case .editing:
            return themeProvider.theme.colors.cadaEuroAccent.opacity(0.05)
        case .deleting:
            return themeProvider.theme.colors.cadaEuroError.opacity(0.05)
        case .selected:
            return themeProvider.theme.colors.cadaEuroAccent.opacity(0.1)
        }
    }
    
    private var borderColor: Color {
        switch state {
        case .normal:
            return Color.clear
        case .editing:
            return themeProvider.theme.colors.cadaEuroAccent
        case .deleting:
            return themeProvider.theme.colors.cadaEuroError
        case .selected:
            return themeProvider.theme.colors.cadaEuroAccent
        }
    }
    
    private var borderWidth: CGFloat {
        state == .normal ? 0 : 1.0
    }
    
    private var textColor: Color {
        state == .deleting ? 
        themeProvider.theme.colors.cadaEuroTextTertiary : 
        themeProvider.theme.colors.cadaEuroTextPrimary
    }
    
    private var priceColor: Color {
        switch state {
        case .normal, .editing, .selected:
            return themeProvider.theme.colors.cadaEuroAccent
        case .deleting:
            return themeProvider.theme.colors.cadaEuroTextTertiary
        }
    }
    
    private var scaleEffect: CGFloat {
        isPressed ? themeProvider.theme.animation.pressedScale : 1.0
    }
    
    private var shadowColor: Color {
        state == .selected ? 
        themeProvider.theme.colors.cadaEuroAccent.opacity(0.2) : 
        themeProvider.theme.colors.cadaEuroTextTertiary.opacity(0.15)
    }
    
    private var shadowRadius: CGFloat {
        if isPressed {
            return state == .selected ? 2 : 2
        }
        return state == .selected ? 4 : 6
    }
    
    private var shadowOffset: CGFloat {
        if isPressed {
            return state == .selected ? 1 : 1
        }
        return state == .selected ? 2 : 3
    }
    
    // MARK: - Gestures (swipe para delete mantido)
    
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 15, coordinateSpace: .local)
            .onChanged { value in
                guard onDelete != nil else { return }
                
                // Determinar se o gesto é principalmente horizontal
                let horizontalAmount = abs(value.translation.width)
                let verticalAmount = abs(value.translation.height)
                
                // Se o gesto for mais horizontal que vertical, tratar como swipe
                if horizontalAmount > verticalAmount {
                    isScrollEnabled = false
                    let translation = value.translation.width
                    if translation < 0 {
                        // Atualizar a posição sem animação durante o arrasto
                        dragOffset = CGSize(width: max(translation, -80), height: 0)
                        
                        if translation < -40 && !showingDeleteAction {
                            // Usar animação mais simples
                            withAnimation(.easeOut(duration: 0.2)) {
                                showingDeleteAction = true
                            }
                        }
                    }
                } else {
                    // Se for mais vertical, permitir scroll
                    isScrollEnabled = true
                }
            }
            .onEnded { value in
                // Verificar se o gesto foi principalmente horizontal
                let horizontalAmount = abs(value.translation.width)
                let verticalAmount = abs(value.translation.height)
                
                if horizontalAmount > verticalAmount {
                    let translation = value.translation.width
                    
                    if translation < -60 {
                        // Usar animação mais simples e previsível
                        withAnimation(.easeOut(duration: 0.2)) {
                            dragOffset = CGSize(width: -80, height: 0)
                            showingDeleteAction = true
                        }
                    } else {
                        // Usar animação mais simples e previsível
                        withAnimation(.easeOut(duration: 0.2)) {
                            dragOffset = .zero
                            showingDeleteAction = false
                        }
                    }
                }
                
                // Reativar scroll em qualquer caso
                isScrollEnabled = true
            }
    }
    
    // MARK: - Accessibility
    
    private var accessibilityLabel: String {
        // ✅ USAR VALIDATORS: Validação antes de acessibilidade
        let validation = ProductValidator.validate(
            name: item.name,
            price: item.price,
            quantity: item.quantity,
            captureMethod: item.captureMethod
        )
        
        // ✅ DateExtensions + DoubleExtensions para formatação acessível
        var label = "\(item.name), \(item.totalPrice.asCurrencyAccessible)"
        
        // ✅ USAR DateExtensions: Data acessível para VoiceOver
        label += ", adicionado \(item.dateAdded.asAccessibleDate)"
        
        if item.quantity > 1 {
            label += ", \(item.quantity) unidades"
        }
        
        // ✅ USAR VALIDATORS: Adicionar avisos se houver problemas
        if !validation.isValid {
            label += " (requer verificação)"
        } else if !validation.warnings.isEmpty {
            label += " (verificar dados)"
        }
        
        return label
    }
    
    private var accessibilityHint: String {
        var hints: [String] = []
        
        if onQuantityChange != nil {
            hints.append("Use os controlos + e - para ajustar quantidade")
        }
        
        if onDelete != nil {
            hints.append("Deslize para eliminar")
        }
        
        return hints.joined(separator: ", ")
    }
    
    private var accessibilityTraits: AccessibilityTraits {
        var traits: AccessibilityTraits = []
        
        if state == .selected {
            _ = traits.insert(.isSelected)
        }
        
        if onQuantityChange != nil {
            _ = traits.insert(.isButton)
        }
        
        return traits
    }
}

// MARK: - Preview Data

extension ShoppingItem {
    static let sampleItems: [ShoppingItem] = [
        ShoppingItem(name: "Leite", price: 1.29, quantity: 2, captureMethod: .scanner),
        ShoppingItem(name: "Pão de Forma Integral", price: 2.15, captureMethod: .voice),
        ShoppingItem(name: "Maçãs (1kg)", price: 3.45, quantity: 1, captureMethod: .manual),
        ShoppingItem(name: "Cereais Estrelitas", price: 4.99, captureMethod: .scanner),
        ShoppingItem(name: "Iogurte Natural", price: 0.89, quantity: 4, captureMethod: .voice)
    ]
}

#Preview("Item Cards") {
    ScrollView {
        LazyVStack(spacing: 12) {
            ForEach(ShoppingItem.sampleItems) { item in
                ItemCard(
                    item: item,
                    onDelete: { print("Delete \(item.name)") },
                    onQuantityChange: { newQuantity in
                        print("Change \(item.name) quantity to \(newQuantity)")
                    }
                )
            }
        }
        .padding()
    }
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("Item Card Dark") {
    ItemCard(
        item: ShoppingItem.sampleItems[0],
        onDelete: { print("Delete") },
        onQuantityChange: { _ in print("Quantity changed") }
    )
    .padding()
    .background(ThemeProvider.darkPreview.theme.colors.cadaEuroBackground)
    .themeProvider(.darkPreview)
    .preferredColorScheme(.dark)
}
