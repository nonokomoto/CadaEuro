import SwiftUI

/// Diálogo específico para confirmação de produtos OCR
/// Reutiliza toda a lógica do ManualInputForm existente
public struct ProductConfirmationDialog: View {
    @Environment(\.themeProvider) private var themeProvider
    
    private let productData: ProductData
    private let onConfirm: (ProductData) -> Void
    private let onCancel: () -> Void
    
    @State private var isVisible = false
    @State private var productName: String = ""
    @State private var priceText: String = ""
    @State private var nameError: ValidationError?
    @State private var priceError: ValidationError?
    
    @FocusState private var focusedField: Field?
    
    private enum Field: Hashable {
        case name, price
    }
    
    public init(
        productData: ProductData,
        onConfirm: @escaping (ProductData) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.productData = productData
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
    
    public var body: some View {
        ZStack {
            // Overlay escurecido
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    handleCancel()
                }
            
            // Dialog card
            dialogCard
                .scaleEffect(isVisible ? 1.0 : 0.9)
                .opacity(isVisible ? 1.0 : 0.0)
        }
        .onAppear {
            // Inicializar com dados do OCR
            productName = productData.name
            priceText = String(productData.price).replacingOccurrences(of: ".", with: ",")
            
            withAnimation(themeProvider.theme.animation.spring) {
                isVisible = true
            }
            
            // Foco automático após animação
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                focusedField = .name
            }
        }
    }
    
    @ViewBuilder
    private var dialogCard: some View {
        VStack(spacing: themeProvider.theme.spacing.xl) {
            // Header
            headerView
            
            // Form Fields - Reutilizados do ManualInputForm
            VStack(spacing: themeProvider.theme.spacing.lg) {
                productNameField
                priceField
            }
            
            // Action Buttons
            actionButtons
        }
        .padding(themeProvider.theme.spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: themeProvider.theme.border.cardRadius)
                .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
                .shadow(
                    color: themeProvider.theme.colors.cadaEuroTextTertiary.opacity(0.2),
                    radius: 20,
                    x: 0,
                    y: 10
                )
        )
        .frame(maxWidth: 340)
        .padding(themeProvider.theme.spacing.xl)
    }
    
    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: themeProvider.theme.spacing.md) {
            // Ícone de confirmação
            ZStack {
                Circle()
                    .fill(themeProvider.theme.colors.cadaEuroAccent.opacity(0.1))
                    .frame(width: 64, height: 64)
                
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
            }
            
            // Título e subtítulo
            VStack(spacing: themeProvider.theme.spacing.xs) {
                Text("Confirmar Produto")
                    .font(themeProvider.theme.typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                
                Text("Produto detetado via OCR. Verifique se está correto:")
                    .font(themeProvider.theme.typography.bodyMedium)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // ✅ REUTILIZAR: Campos idênticos ao ManualInputForm
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
                        handleConfirm()
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
        VStack(spacing: themeProvider.theme.spacing.md) {
            // ✅ REUTILIZAR: ActionButton existente
            ActionButton(
                "Adicionar à Lista",
                systemImage: "checkmark",
                type: .primary,
                isEnabled: isFormValid
            ) {
                handleConfirm()
            }
            
            ActionButton(
                "Cancelar",
                type: .secondary
            ) {
                handleCancel()
            }
        }
    }
    
    // ✅ REUTILIZAR: Lógica de validação idêntica
    private var isFormValid: Bool {
        nameError == nil && priceError == nil && 
        !productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !priceText.isEmpty && parsePrice(from: priceText) > 0
    }
    
    private func validateProductName(_ name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            nameError = .emptyName
        } else if trimmedName.count > 100 {
            nameError = .nameTooLong
        } else {
            nameError = nil
        }
    }
    
    private func formatAndValidatePrice(_ text: String) {
        // Remove tudo exceto dígitos e vírgula
        let cleaned = text.replacingOccurrences(of: "[^0-9,]", with: "", options: .regularExpression)
        
        // Permite apenas uma vírgula
        let components = cleaned.components(separatedBy: ",")
        var formatted = components.first ?? ""
        
        if components.count > 1 {
            let decimals = String(components[1].prefix(2)) // Máx 2 casas decimais
            formatted += "," + decimals
        }
        
        // Atualiza apenas se mudou
        if formatted != priceText {
            priceText = formatted
        }
        
        // Validação
        let price = parsePrice(from: formatted)
        
        if formatted.isEmpty {
            priceError = .invalidPrice
        } else if price <= 0 || price > 9999.99 {
            priceError = .priceOutOfRange
        } else {
            priceError = nil
        }
    }
    
    private func parsePrice(from text: String) -> Double {
        let normalizedText = text.replacingOccurrences(of: ",", with: ".")
        return Double(normalizedText) ?? 0.0
    }
    
    private func handleConfirm() {
        guard isFormValid else { return }
        
        let trimmedName = productName.trimmingCharacters(in: .whitespacesAndNewlines)
        let price = parsePrice(from: priceText)
        let confirmedProduct = ProductData(name: trimmedName, price: price)
        
        withAnimation(themeProvider.theme.animation.quick) {
            isVisible = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onConfirm(confirmedProduct)
        }
    }
    
    private func handleCancel() {
        withAnimation(themeProvider.theme.animation.quick) {
            isVisible = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onCancel()
        }
    }
}

// ✅ Extension helper para facilitar uso
public extension View {
    func productConfirmationDialog(
        isPresented: Binding<Bool>,
        productData: ProductData?,
        onConfirm: @escaping (ProductData) -> Void
    ) -> some View {
        self.overlay {
            if isPresented.wrappedValue, let productData = productData {
                ProductConfirmationDialog(
                    productData: productData,
                    onConfirm: { confirmedProduct in
                        onConfirm(confirmedProduct)
                        isPresented.wrappedValue = false
                    },
                    onCancel: {
                        isPresented.wrappedValue = false
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(ThemeProvider.preview.theme.animation.spring, value: isPresented.wrappedValue)
    }
}

#Preview("Product Confirmation Dialog") {
    @Previewable @State var showingProductConfirmation = false
    
    let sampleProduct = ProductData(name: "Leite Mimosa", price: 1.29)
    
    VStack(spacing: 32) {
        Text("Scanner OCR")
            .font(.largeTitle)
        
        ActionButton("Simular OCR Result", systemImage: "camera", type: .primary) {
            showingProductConfirmation = true
        }
    }
    .padding()
    .productConfirmationDialog(
        isPresented: $showingProductConfirmation,
        productData: sampleProduct
    ) { confirmedProduct in
        print("Produto confirmado: \(confirmedProduct.name) - €\(confirmedProduct.price)")
    }
    .themeProvider(.preview)
}

#Preview("Product Confirmation Dialog - Dark") {
    @Previewable @State var showingProductConfirmation = false
    
    let sampleProduct = ProductData(name: "Cereais Estrelitas", price: 4.99)
    
    VStack(spacing: 32) {
        Text("OCR Scanner")
            .font(.largeTitle)
        
        ActionButton("Simular Detecção", systemImage: "camera.viewfinder", type: .primary) {
            showingProductConfirmation = true
        }
    }
    .padding()
    .productConfirmationDialog(
        isPresented: $showingProductConfirmation,
        productData: sampleProduct
    ) { confirmedProduct in
        print("Confirmado: \(confirmedProduct.name) - €\(confirmedProduct.price)")
    }
    .themeProvider(.darkPreview)
    .preferredColorScheme(.dark)
}