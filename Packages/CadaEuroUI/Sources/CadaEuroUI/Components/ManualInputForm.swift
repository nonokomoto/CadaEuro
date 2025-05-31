import SwiftUI
import CadaEuroKit  

/// Dados do produto para entrada manual
public struct ProductData: Sendable, Equatable {
    public let name: String
    public let price: Double
    public let captureMethod: CaptureMethod  
    
    public init(name: String, price: Double, captureMethod: CaptureMethod = .manual) {  
        self.name = name
        self.price = price
        self.captureMethod = captureMethod
    }
}

/// Erros de validação para entrada manual
public enum ValidationError: LocalizedError, Sendable, Equatable {
    case emptyName
    case nameTooLong
    case invalidPrice
    case priceOutOfRange
    
    public var errorDescription: String? {
        switch self {
        case .emptyName: return "Nome do produto é obrigatório"
        case .nameTooLong: return "Nome muito longo (máx. \(BusinessRules.maxProductNameLength) caracteres)"
        case .invalidPrice: return "Preço inválido"
        case .priceOutOfRange: return "Preço deve estar entre \(BusinessRules.minPrice.asCurrency) e \(BusinessRules.maxPrice.asCurrency)" 
        }
    }
}

/// Formulário minimalista para entrada manual de produtos
public struct ManualInputForm: View {
    @Environment(\.themeProvider) private var themeProvider
    
    private let onAdd: (ProductData) -> Void
    private let onCancel: () -> Void
    
    @State private var productName: String = ""
    @State private var priceText: String = ""
    @State private var nameError: ValidationError?
    @State private var priceError: ValidationError?
    @State private var isPressed = false
    
    @FocusState private var focusedField: Field?
    
    private enum Field: Hashable {
        case name, price
    }
    
    public init(
        onAdd: @escaping (ProductData) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.onAdd = onAdd
        self.onCancel = onCancel
    }
    
    public var body: some View {
        VStack(spacing: themeProvider.theme.spacing.xl) {
            // Header
            headerView
            
            // Form Fields
            VStack(spacing: themeProvider.theme.spacing.lg) {
                productNameField
                priceField
            }
            
            // Action Buttons
            actionButtons
            
            Spacer(minLength: 0)
        }
        .padding(themeProvider.theme.spacing.xl)
        .background(themeProvider.theme.colors.cadaEuroBackground)
        .onAppear {
            // Foco automático no nome do produto
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusedField = .name
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: themeProvider.theme.spacing.sm) {
            Text("Adicionar Produto")
                .font(themeProvider.theme.typography.titleLarge)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
            
            Text("Preencha o nome e preço do produto")
                .font(themeProvider.theme.typography.bodyMedium)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    @ViewBuilder
    private var productNameField: some View {
        VStack(alignment: .leading, spacing: themeProvider.theme.spacing.xs) {
            Text("Nome do Produto")
                .font(themeProvider.theme.typography.bodyMedium)
                .fontWeight(.medium)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
            
            TextField("Ex: Leite Mimosa", text: $productName)
                .font(themeProvider.theme.typography.bodyLarge)
                .focused($focusedField, equals: .name)
#if os(iOS)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
#endif
                .onSubmit {
                    focusedField = .price
                }
                .onChange(of: productName) { _, newValue in
                    validateProductName(newValue)
                }
                .padding(themeProvider.theme.spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: themeProvider.theme.border.inputRadius)
                        .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
                        .stroke(
                            nameError != nil ? themeProvider.theme.colors.cadaEuroError : 
                            focusedField == .name ? themeProvider.theme.colors.cadaEuroAccent : 
                            Color.clear,
                            lineWidth: nameError != nil ? 2 : 1
                        )
                )
            
            // Error message
            if let nameError = nameError {
                Text(nameError.localizedDescription)
                    .font(themeProvider.theme.typography.bodySmall)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroError)
                    .transition(.opacity)
            }
        }
        .animation(themeProvider.theme.animation.quick, value: nameError)
    }
    
    @ViewBuilder
    private var priceField: some View {
        VStack(alignment: .leading, spacing: themeProvider.theme.spacing.xs) {
            Text("Preço")
                .font(themeProvider.theme.typography.bodyMedium)
                .fontWeight(.medium)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
            
            HStack(spacing: themeProvider.theme.spacing.sm) {
                Text("€")
                    .font(themeProvider.theme.typography.bodyLarge)
                    .fontWeight(.medium)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                
                TextField("0,00", text: $priceText)
                    .font(themeProvider.theme.typography.bodyLarge)
                    .focused($focusedField, equals: .price)
#if os(iOS)
                    .keyboardType(.decimalPad)
                    .submitLabel(.done)
#endif
                    .onSubmit {
                        handleAddProduct()
                    }
                    .onChange(of: priceText) { _, newValue in
                        formatAndValidatePrice(newValue)
                    }
            }
            .padding(themeProvider.theme.spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: themeProvider.theme.border.inputRadius)
                    .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
                    .stroke(
                        priceError != nil ? themeProvider.theme.colors.cadaEuroError :
                        focusedField == .price ? themeProvider.theme.colors.cadaEuroAccent :
                        Color.clear,
                        lineWidth: priceError != nil ? 2 : 1
                    )
            )
            
            // Error message
            if let priceError = priceError {
                Text(priceError.localizedDescription)
                    .font(themeProvider.theme.typography.bodySmall)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroError)
                    .transition(.opacity)
            }
        }
        .animation(themeProvider.theme.animation.quick, value: priceError)
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: themeProvider.theme.spacing.lg) {
            // ✅ Usar ActionButton existente ao invés de implementação custom
            ActionButton(
                "Adicionar à Lista",
                systemImage: "plus",
                type: .primary,
                isEnabled: isFormValid
            ) {
                handleAddProduct()
            }
            
            // ✅ Usar ActionButton para cancelar também
            ActionButton(
                "Cancelar",
                type: .secondary
            ) {
                onCancel()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        nameError == nil && priceError == nil && 
        !productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !priceText.isEmpty && parsePrice(from: priceText) > 0
    }
    
    // MARK: - Methods
    
    private func validateProductName(_ name: String) {
        // ✅ USAR StringExtensions: Validação centralizada
        if !name.isValidProductName {
            if name.trimmedAndCleaned.isEmpty {
                nameError = .emptyName
            } else if name.trimmedAndCleaned.count > BusinessRules.maxProductNameLength {
                nameError = .nameTooLong
            } else {
                nameError = .emptyName // Fallback para outros casos inválidos
            }
        } else {
            nameError = nil
        }
    }
    
    private func formatAndValidatePrice(_ text: String) {
        // ✅ USAR StringExtensions: Validação de formato de preço
        if !text.isValidPriceInput && !text.isEmpty {
            // Limpa caracteres inválidos automaticamente
            let cleaned = text.filter { "0123456789,".contains($0) }
            
            // Permite apenas uma vírgula
            let components = cleaned.components(separatedBy: ",")
            var formatted = components.first ?? ""
            
            if components.count > 1 {
                let decimals = String(components[1].prefix(2))
                formatted += "," + decimals
            }
            
            if formatted != priceText {
                priceText = formatted
            }
        }
        
        // ✅ USAR StringExtensions: Parse português integrado
        if text.isEmpty {
            priceError = .invalidPrice
        } else if let price = text.extractPortuguesePrice(), price.isValidPrice {
            priceError = nil
        } else {
            priceError = .priceOutOfRange
        }
    }
    
    private func parsePrice(from text: String) -> Double {
        // ✅ USAR StringExtensions: Parse centralizado
        return text.extractPortuguesePrice() ?? 0.0
    }
    
    private func handleAddProduct() {
        guard isFormValid else { return }
        
        // ✅ USAR StringExtensions: Normalização de nome de produto
        let normalizedName = productName.normalizedProductName
        let price = parsePrice(from: priceText)
        
        let productData = ProductData(name: normalizedName, price: price, captureMethod: .manual)
        onAdd(productData)
        
        // Reset form com limpeza padronizada
        productName = ""
        priceText = ""
        nameError = nil
        priceError = nil
        focusedField = .name
    }
}

#Preview("Manual Input Form") {
    ManualInputForm { productData in
        print("Product added: \(productData.name) - €\(productData.price)")
    } onCancel: {
        print("Cancelled")
    }
    .themeProvider(.preview)
}

#Preview("Manual Input Form - Dark") {
    ManualInputForm { productData in
        print("Product added: \(productData.name) - €\(productData.price)")
    } onCancel: {
        print("Cancelled")
    }
    .themeProvider(.darkPreview)
    .preferredColorScheme(.dark)
}
