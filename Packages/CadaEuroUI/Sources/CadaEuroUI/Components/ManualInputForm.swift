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
        initialData: ProductData? = nil,
        onAdd: @escaping (ProductData) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.onAdd = onAdd
        self.onCancel = onCancel
        
        // Pre-fill com dados do scanner se fornecidos
        if let data = initialData {
            self._productName = State(initialValue: data.name)
            self._priceText = State(initialValue: String(format: "%.2f", data.price).replacingOccurrences(of: ".", with: ","))
        }
    }
    
    public var body: some View {
        VStack(spacing: themeProvider.theme.spacing.xl) {
           // ✅ HeaderView finalizado
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
            // ✅ Configuração inicial baseada nos dados fornecidos
            if !productName.isEmpty || !priceText.isEmpty {
                // Validar dados pré-preenchidos
                if !productName.isEmpty {
                    validateProductName(productName)
                }
                if !priceText.isEmpty {
                    formatAndValidatePrice(priceText)
                }
                
                // Foco no primeiro campo com erro ou no nome
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if nameError != nil {
                        focusedField = .name
                    } else if priceError != nil {
                        focusedField = .price
                    } else {
                        focusedField = .name  // Default
                    }
                }
            } else {
                // Foco automático no nome do produto para entrada manual limpa
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    focusedField = .name
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: themeProvider.theme.spacing.sm) {
            // ✅ Instrução contextual baseada na origem dos dados
            if !productName.isEmpty || !priceText.isEmpty {
                Text("Confirme ou edite os dados detectados")
                    .font(themeProvider.theme.typography.bodyMedium)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Preencha o nome e preço do produto")
                    .font(themeProvider.theme.typography.bodyMedium)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                    .multilineTextAlignment(.center)
            }
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
                
                TextField("1,99", text: $priceText)
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
            
            // ✅ Usar ActionButton para cancelar também com haptic feedback
            ActionButton(
                "Cancelar",
                type: .secondary
            ) {
                // ✅ Haptic feedback para cancelamento
                HapticManager.shared.feedback(.light)
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
        // Verificar apenas se o nome não está vazio
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            nameError = .emptyName
        } else {
            nameError = nil
            // Não aplicar sugestões de formatação, apenas aceitar o nome como está
        }
    }
    
    private func formatAndValidatePrice(_ text: String) {
        // ✅ USAR VALIDATORS: Validação de preço com contexto manual
        guard let price = text.extractPortuguesePrice() else {
            if text.isEmpty {
                priceError = .invalidPrice
            } else {
                priceError = .priceOutOfRange
            }
            return
        }
        
        let validation = ProductValidator.validatePrice(price, captureMethod: .manual)
        
        if !validation.isValid {
            if let firstError = validation.errors.first {
                switch firstError {
                case .invalidPrice(let reason):
                    if reason.contains("limites") {
                        priceError = .priceOutOfRange
                    } else {
                        priceError = .invalidPrice
                    }
                default:
                    priceError = .invalidPrice
                }
            } else {
                priceError = .invalidPrice
            }
        } else {
            priceError = nil
            
            // ✅ USAR VALIDATORS: Aplicar sugestões de arredondamento
            if !validation.suggestions.isEmpty {
                for suggestion in validation.suggestions {
                    if suggestion.contains("arredondado") {
                        // Aplicar arredondamento sugerido
                        let rounded = price.roundedToEuro
                        if rounded != price {
                            priceText = rounded.asEditablePrice
                        }
                    }
                }
            }
        }
    }
    
    private func parsePrice(from text: String) -> Double {
        // ✅ USAR StringExtensions: Parse centralizado
        return text.extractPortuguesePrice() ?? 0.0
    }
    
    private func handleAddProduct() {
        guard isFormValid else { return }
        
        let price = parsePrice(from: priceText)
        
        // Validar apenas o preço, o nome já foi validado anteriormente
        let priceValidation = ProductValidator.validatePrice(price, captureMethod: .manual)
        
        if priceValidation.isValid {
            // Usar o nome como está, sem normalização adicional
            let trimmedName = productName.trimmingCharacters(in: .whitespacesAndNewlines)
            let productData = ProductData(name: trimmedName, price: price, captureMethod: .manual)
            onAdd(productData)
            
            // Reset form
            productName = ""
            priceText = ""
            nameError = nil
            priceError = nil
            focusedField = .name
        } else {
            // Mostrar erros de validação apenas para o preço
            if let firstError = priceValidation.errors.first {
                print("⚠️ Price validation error: \(firstError.localizedDescription)")
            }
        }
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

#Preview("Manual Input Form - Pre-filled") {
    ManualInputForm(
        initialData: ProductData(name: "Leite Mimosa", price: 1.29, captureMethod: .scanner)
    ) { productData in
        print("Product confirmed: \(productData.name) - €\(productData.price)")
    } onCancel: {
        print("Cancelled")
    }
    .themeProvider(.preview)
}

#Preview("Manual Input Form - Long Name") {
    ManualInputForm(
        initialData: ProductData(name: "Leite Meio Gordo UHT Pasteurizado Enriquecido", price: 2.49, captureMethod: .scanner)
    ) { productData in
        print("Product confirmed: \(productData.name) - €\(productData.price)")
    } onCancel: {
        print("Cancelled")
    }
    .themeProvider(.preview)
}
