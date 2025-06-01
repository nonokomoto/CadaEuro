import Foundation

// MARK: - Validation Error Types

/// Erros específicos de validação da aplicação CadaEuro
///
/// Enum tipado que define todos os casos de erro possíveis na validação,
/// com mensagens localizadas e contexto específico para debugging.
///
/// ## Integração com Fase 1
/// - **Constants Integration**: Usa BusinessRules para limites
/// - **StringExtensions Integration**: Conecta com validações básicas  
/// - **DoubleExtensions Integration**: Usa formatação monetária
/// - **CaptureMethod Integration**: Validações específicas por método
///
/// ## Exemplo de Uso
/// ```swift
/// do {
///     try ProductValidator.validate(name: productName, price: price)
/// } catch ValidationError.invalidPrice(let details) {
///     showError("Preço inválido: \(details)")
/// }
/// ```
public enum ValidationError: LocalizedError, Sendable {
    // MARK: - Product Validation Errors
    
    /// Nome de produto inválido
    case invalidProductName(reason: String)
    
    /// Preço inválido
    case invalidPrice(reason: String)
    
    /// Quantidade inválida
    case invalidQuantity(reason: String)
    
    // MARK: - List Validation Errors
    
    /// Nome de lista inválido
    case invalidListName(reason: String)
    
    /// Lista vazia ou inválida
    case invalidList(reason: String)
    
    // MARK: - Input Method Specific Errors
    
    /// Erro específico de OCR
    case ocrValidationFailed(reason: String, confidence: Double)
    
    /// Erro específico de Voice
    case voiceValidationFailed(reason: String, transcription: String)
    
    /// Erro específico de entrada manual
    case manualInputInvalid(reason: String)
    
    // MARK: - Complex Validation Errors
    
    /// Múltiplos erros de validação
    case multipleErrors([ValidationError])
    
    /// Erro de regra de negócio
    case businessRuleViolation(rule: String, reason: String)
    
    // MARK: - LocalizedError Implementation
    
    public var errorDescription: String? {
        switch self {
        case .invalidProductName(let reason):
            return "Nome de produto inválido: \(reason)"
            
        case .invalidPrice(let reason):
            return "Preço inválido: \(reason)"
            
        case .invalidQuantity(let reason):
            return "Quantidade inválida: \(reason)"
            
        case .invalidListName(let reason):
            return "Nome de lista inválido: \(reason)"
            
        case .invalidList(let reason):
            return "Lista inválida: \(reason)"
            
        case .ocrValidationFailed(let reason, let confidence):
            return "Falha na validação OCR: \(reason) (confiança: \(String(format: "%.1f", confidence * 100))%)"
            
        case .voiceValidationFailed(let reason, let transcription):
            return "Falha na validação de voz: \(reason) (transcrição: '\(transcription)')"
            
        case .manualInputInvalid(let reason):
            return "Entrada manual inválida: \(reason)"
            
        case .multipleErrors(let errors):
            let descriptions = errors.compactMap { $0.errorDescription }
            return "Múltiplos erros: \(descriptions.joined(separator: "; "))"
            
        case .businessRuleViolation(let rule, let reason):
            return "Violação da regra '\(rule)': \(reason)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidProductName:
            return "Use entre \(BusinessRules.minProductNameLength) e \(BusinessRules.maxProductNameLength) caracteres"
            
        case .invalidPrice:
            return "Use um preço entre \(BusinessRules.minPrice.asCurrency) e \(BusinessRules.maxPrice.asCurrency)"
            
        case .invalidQuantity:
            return "Use uma quantidade entre \(BusinessRules.minQuantity) e \(BusinessRules.maxQuantity)"
            
        case .ocrValidationFailed:
            return "Tente novamente ou use entrada manual"
            
        case .voiceValidationFailed:
            return "Repita mais devagar ou use entrada manual"
            
        case .manualInputInvalid:
            return "Verifique se todos os campos estão preenchidos corretamente"
            
        default:
            return "Verifique os dados e tente novamente"
        }
    }
}

// MARK: - Validation Result Type

/// Resultado de validação tipado
///
/// Encapsula resultado de validação com informações detalhadas
/// incluindo warnings, suggestions e metadata para UX avançada.
public struct ValidationResult: Sendable {
    /// Indica se a validação passou
    public let isValid: Bool
    
    /// Erros encontrados (se houver)
    public let errors: [ValidationError]
    
    /// Warnings não críticos
    public let warnings: [String]
    
    /// Sugestões de melhoria
    public let suggestions: [String]
    
    /// Metadata adicional para debugging
    public let metadata: [String: String]
    
    /// Resultado de sucesso
    public static func success(warnings: [String] = [], suggestions: [String] = []) -> ValidationResult {
        return ValidationResult(
            isValid: true,
            errors: [],
            warnings: warnings,
            suggestions: suggestions,
            metadata: [:]
        )
    }
    
    /// Resultado de falha
    public static func failure(errors: [ValidationError], warnings: [String] = []) -> ValidationResult {
        return ValidationResult(
            isValid: false,
            errors: errors,
            warnings: warnings,
            suggestions: [],
            metadata: [:]
        )
    }
    
    /// Resultado de falha com erro único
    public static func failure(error: ValidationError) -> ValidationResult {
        return failure(errors: [error])
    }
}

// MARK: - Product Validator

/// Validador especializado para produtos
///
/// Centraliza todas as validações relacionadas a produtos, integrando
/// as fundações da Fase 1 em um sistema robusto e extensível.
///
/// ## Integrações da Fase 1
/// - **StringExtensions**: `.isValidProductName`, `.normalizedProductName`, `.sanitized`
/// - **DoubleExtensions**: `.isValidPrice`, `.isValidMonetaryValue`, `.asCurrency`
/// - **Constants**: `BusinessRules` para limites e regras
/// - **CaptureMethod**: Validações específicas por método de captura
public final class ProductValidator: @unchecked Sendable {
    
    // MARK: - Main Validation Methods
    
    /// Validação completa de produto
    ///
    /// - Parameters:
    ///   - name: Nome do produto a validar
    ///   - price: Preço do produto
    ///   - quantity: Quantidade (opcional, default: 1)
    ///   - captureMethod: Método de captura para validações específicas
    /// - Returns: ValidationResult com resultado detalhado
    /// - Integration: Usa todas as fundações da Fase 1
    public static func validate(
        name: String,
        price: Double,
        quantity: Int = 1,
        captureMethod: CaptureMethod? = nil
    ) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        var suggestions: [String] = []
        
        // ✅ INTEGRAÇÃO StringExtensions - Validação de nome
        let nameValidation = validateProductName(name)
        if !nameValidation.isValid {
            errors.append(contentsOf: nameValidation.errors)
        }
        warnings.append(contentsOf: nameValidation.warnings)
        suggestions.append(contentsOf: nameValidation.suggestions)
        
        // ✅ INTEGRAÇÃO DoubleExtensions - Validação de preço
        let priceValidation = validatePrice(price, captureMethod: captureMethod)
        if !priceValidation.isValid {
            errors.append(contentsOf: priceValidation.errors)
        }
        warnings.append(contentsOf: priceValidation.warnings)
        suggestions.append(contentsOf: priceValidation.suggestions)
        
        // ✅ INTEGRAÇÃO Constants - Validação de quantidade
        let quantityValidation = validateQuantity(quantity)
        if !quantityValidation.isValid {
            errors.append(contentsOf: quantityValidation.errors)
        }
        
        // ✅ INTEGRAÇÃO CaptureMethod - Validações específicas
        if let method = captureMethod {
            let methodValidation = validateForCaptureMethod(
                name: name,
                price: price,
                method: method
            )
            if !methodValidation.isValid {
                errors.append(contentsOf: methodValidation.errors)
            }
            warnings.append(contentsOf: methodValidation.warnings)
        }
        
        return errors.isEmpty 
            ? ValidationResult.success(warnings: warnings, suggestions: suggestions)
            : ValidationResult.failure(errors: errors, warnings: warnings)
    }
    
    /// Validação rápida (apenas sucesso/falha)
    ///
    /// - Parameters:
    ///   - name: Nome do produto
    ///   - price: Preço do produto
    /// - Returns: Bool indicando se é válido
    /// - Use Case: Validação em tempo real durante digitação
    public static func isValid(name: String, price: Double) -> Bool {
        return validate(name: name, price: price).isValid
    }
    
    // MARK: - Specific Validation Methods
    
    /// Validação específica de nome de produto
    ///
    /// - Parameter name: Nome a validar
    /// - Returns: ValidationResult detalhado
    /// - Integration: ✅ StringExtensions (.isValidProductName, .sanitized, .normalizedProductName)
    public static func validateProductName(_ name: String) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        var suggestions: [String] = []
        
        // ✅ USA StringExtensions.isValidProductName
        guard name.isValidProductName else {
            let reason = determineNameInvalidReason(name)
            errors.append(.invalidProductName(reason: reason))
            return ValidationResult.failure(errors: errors)
        }
        
        // ✅ USA StringExtensions.sanitized para segurança
        let sanitized = name.sanitized
        if sanitized != name {
            warnings.append("Nome foi sanitizado para segurança")
            suggestions.append("Use: '\(sanitized)'")
        }
        
        // ✅ USA StringExtensions.normalizedProductName para formatação
        let normalized = name.normalizedProductName
        if normalized != name {
            suggestions.append("Sugestão de formatação: '\(normalized)'")
        }
        
        // ✅ USA StringExtensions.textConfidenceScore para qualidade
        let confidence = name.textConfidenceScore
        if confidence < 0.7 {
            warnings.append("Qualidade do texto pode ser melhorada (confiança: \(String(format: "%.1f", confidence * 100))%)")
        }
        
        return ValidationResult.success(warnings: warnings, suggestions: suggestions)
    }
    
    /// Validação específica de preço
    ///
    /// - Parameters:
    ///   - price: Preço a validar
    ///   - captureMethod: Método de captura para contexto
    /// - Returns: ValidationResult detalhado
    /// - Integration: ✅ DoubleExtensions (.isValidPrice, .isValidMonetaryValue, .asCurrency)
    public static func validatePrice(_ price: Double, captureMethod: CaptureMethod? = nil) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        var suggestions: [String] = []
        
        // ✅ USA DoubleExtensions.isValidMonetaryValue para verificação completa
        guard price.isValidMonetaryValue else {
            let reason = determinePriceInvalidReason(price)
            errors.append(.invalidPrice(reason: reason))
            return ValidationResult.failure(errors: errors)
        }
        
        // ✅ USA DoubleExtensions.isValidPrice para limites de negócio  
        guard price.isValidPrice else {
            let reason = "Preço fora dos limites permitidos (\(BusinessRules.minPrice.asCurrency) - \(BusinessRules.maxPrice.asCurrency))"
            errors.append(.invalidPrice(reason: reason))
            return ValidationResult.failure(errors: errors)
        }
        
        // ✅ USA DoubleExtensions.roundedToEuro para precisão
        let rounded = price.roundedToEuro
        if rounded != price {
            suggestions.append("Preço será arredondado para \(rounded.asCurrency)")
        }
        
        // ✅ INTEGRAÇÃO CaptureMethod - Validações específicas por método
        if let method = captureMethod {
            let methodSpecificValidation = validatePriceForMethod(price, method: method)
            warnings.append(contentsOf: methodSpecificValidation.warnings)
            suggestions.append(contentsOf: methodSpecificValidation.suggestions)
        }
        
        return ValidationResult.success(warnings: warnings, suggestions: suggestions)
    }
    
    /// Validação de quantidade
    ///
    /// - Parameter quantity: Quantidade a validar
    /// - Returns: ValidationResult
    /// - Integration: ✅ Constants (BusinessRules.minQuantity, BusinessRules.maxQuantity)
    public static func validateQuantity(_ quantity: Int) -> ValidationResult {
        // ✅ USA Constants.BusinessRules para limites
        guard quantity >= BusinessRules.minQuantity else {
            let reason = "Quantidade deve ser pelo menos \(BusinessRules.minQuantity)"
            return ValidationResult.failure(error: .invalidQuantity(reason: reason))
        }
        
        guard quantity <= BusinessRules.maxQuantity else {
            let reason = "Quantidade não pode exceder \(BusinessRules.maxQuantity)"
            return ValidationResult.failure(error: .invalidQuantity(reason: reason))
        }
        
        var warnings: [String] = []
        
        // Warnings para quantidades suspeitas
        if quantity > 100 {
            warnings.append("Quantidade muito alta: \(quantity) unidades")
        }
        
        return ValidationResult.success(warnings: warnings)
    }
    
    // MARK: - Capture Method Specific Validations
    
    /// Validação específica por método de captura
    ///
    /// - Parameters:
    ///   - name: Nome do produto
    ///   - price: Preço do produto
    ///   - method: Método de captura usado
    /// - Returns: ValidationResult com validações específicas
    /// - Integration: ✅ CaptureMethod (properties específicas)
    private static func validateForCaptureMethod(
        name: String,
        price: Double,
        method: CaptureMethod
    ) -> ValidationResult {
        var _: [String] = []
        var _: [String] = []
        
        switch method {
        case .scanner:
            // ✅ USA CaptureMethod.scanner properties
            return validateOCRInput(name: name, price: price)
            
        case .voice:
            // ✅ USA CaptureMethod.voice properties
            return validateVoiceInput(name: name, price: price)
            
        case .manual:
            // ✅ USA CaptureMethod.manual properties
            return validateManualInput(name: name, price: price)
        }
    }
    
    /// Validação específica para input OCR
    ///
    /// - Parameters:
    ///   - name: Nome capturado via OCR
    ///   - price: Preço capturado via OCR
    /// - Returns: ValidationResult com validações OCR
    /// - Integration: ✅ StringExtensions (.cleanOCRText, .textConfidenceScore)
    private static func validateOCRInput(name: String, price: Double) -> ValidationResult {
        var warnings: [String] = []
        var suggestions: [String] = []
        
        // ✅ USA StringExtensions.textConfidenceScore
        let confidence = name.textConfidenceScore
        
        if confidence < 0.5 {
            warnings.append("Baixa confiança na leitura OCR (\(String(format: "%.1f", confidence * 100))%)")
            suggestions.append("Verifique se o texto está claro e bem iluminado")
        }
        
        // ✅ USA StringExtensions.cleanOCRText
        let cleaned = name.cleanOCRText
        if cleaned != name {
            suggestions.append("Texto corrigido de OCR: '\(cleaned)'")
        }
        
        // Validação específica para preços OCR
        if price == 0.0 {
            warnings.append("Preço não detectado pelo OCR")
            suggestions.append("Confirme o preço manualmente")
        }
        
        return ValidationResult.success(warnings: warnings, suggestions: suggestions)
    }
    
    /// Validação específica para input de voz
    ///
    /// - Parameters:
    ///   - name: Nome capturado via voz
    ///   - price: Preço capturado via voz
    /// - Returns: ValidationResult com validações de voz
    /// - Integration: ✅ StringExtensions (.extractProductAndPrice)
    private static func validateVoiceInput(name: String, price: Double) -> ValidationResult {
        var warnings: [String] = []
        var suggestions: [String] = []
        
        // ✅ USA StringExtensions.extractProductAndPrice para verificação
        let (extractedProduct, extractedPrice) = name.extractProductAndPrice()
        
        if extractedPrice == nil && price == 0.0 {
            warnings.append("Preço não identificado na transcrição")
            suggestions.append("Repita mencionando o preço claramente")
        }
        
        if extractedProduct.isEmpty {
            warnings.append("Nome do produto não claro na transcrição")
            suggestions.append("Repita o nome do produto mais devagar")
        }
        
        // ✅ USA StringExtensions.textConfidenceScore
        let confidence = name.textConfidenceScore
        if confidence < 0.6 {
            warnings.append("Transcrição pode ter imprecisões (\(String(format: "%.1f", confidence * 100))%)")
        }
        
        return ValidationResult.success(warnings: warnings, suggestions: suggestions)
    }
    
    /// Validação específica para entrada manual
    ///
    /// - Parameters:
    ///   - name: Nome inserido manualmente
    ///   - price: Preço inserido manualmente
    /// - Returns: ValidationResult
    private static func validateManualInput(name: String, price: Double) -> ValidationResult {
        var suggestions: [String] = []
        
        // ✅ USA StringExtensions.normalizedProductName
        let normalized = name.normalizedProductName
        if normalized != name {
            suggestions.append("Sugestão de formatação: '\(normalized)'")
        }
        
        // ✅ USA DoubleExtensions.roundedToEuro
        let rounded = price.roundedToEuro
        if rounded != price {
            suggestions.append("Preço será arredondado para \(rounded.asCurrency)")
        }
        
        return ValidationResult.success(suggestions: suggestions)
    }
    
    // MARK: - Helper Methods
    
    /// Determina razão específica para nome inválido
    ///
    /// - Parameter name: Nome a analisar
    /// - Returns: String com razão específica
    /// - Integration: ✅ Constants (BusinessRules), StringExtensions
    private static func determineNameInvalidReason(_ name: String) -> String {
        let trimmed = name.trimmedAndCleaned
        
        if trimmed.isEmpty {
            return "Nome não pode estar vazio"
        }
        
        if trimmed.count < BusinessRules.minProductNameLength {
            return "Nome deve ter pelo menos \(BusinessRules.minProductNameLength) caractere"
        }
        
        if trimmed.count > BusinessRules.maxProductNameLength {
            return "Nome não pode exceder \(BusinessRules.maxProductNameLength) caracteres"
        }
        
        if trimmed.containsDangerousCharacters {
            return "Nome contém caracteres não permitidos"
        }
        
        return "Nome tem formato inválido"
    }
    
    /// Determina razão específica para preço inválido
    ///
    /// - Parameter price: Preço a analisar
    /// - Returns: String com razão específica
    /// - Integration: ✅ Constants (BusinessRules), DoubleExtensions
    private static func determinePriceInvalidReason(_ price: Double) -> String {
        if !price.isFinite {
            return "Preço deve ser um número válido"
        }
        
        if price.isNaN {
            return "Preço não é um número válido"
        }
        
        if price < BusinessRules.minPrice {
            return "Preço deve ser pelo menos \(BusinessRules.minPrice.asCurrency)"
        }
        
        if price > BusinessRules.maxPrice {
            return "Preço não pode exceder \(BusinessRules.maxPrice.asCurrency)"
        }
        
        return "Preço tem formato inválido"
    }
    
    /// Validação de preço específica por método
    ///
    /// - Parameters:
    ///   - price: Preço a validar
    ///   - method: Método de captura
    /// - Returns: ValidationResult com warnings/suggestions específicos
    /// - Integration: ✅ CaptureMethod properties
    private static func validatePriceForMethod(_ price: Double, method: CaptureMethod) -> ValidationResult {
        var warnings: [String] = []
        var suggestions: [String] = []
        
        // ✅ USA CaptureMethod.estimatedProcessingTime para contexto
        if method.estimatedProcessingTime > 0 {
            let processingTime = method.estimatedProcessingTime
            if processingTime > 2.0 {
                warnings.append("Processamento \(method.title) pode demorar \(Int(processingTime))s")
            }
        }
        
        // ✅ USA CaptureMethod.usesLLMProcessing para aviso
        if method.usesLLMProcessing && price > 100.0 {
            suggestions.append("Preço alto será verificado via IA para precisão")
        }
        
        // ✅ USA CaptureMethod.fallbackMethod para recovery
        if method != .manual {
            suggestions.append("Se houver problemas, use \(method.fallbackMethod.title)")
        }
        
        return ValidationResult.success(warnings: warnings, suggestions: suggestions)
    }
}

// MARK: - List Validator

/// Validador especializado para listas de compras
///
/// Centraliza validações de listas, incluindo nomes, conteúdo e regras de negócio.
public final class ListValidator: @unchecked Sendable {
    
    /// Validação completa de lista
    ///
    /// - Parameters:
    ///   - name: Nome da lista
    ///   - items: Produtos da lista
    /// - Returns: ValidationResult detalhado
    public static func validate(name: String, items: [Any] = []) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        var suggestions: [String] = []
        
        // ✅ INTEGRAÇÃO StringExtensions - Validação de nome
        guard name.isValidListName else {
            let reason = determineListNameInvalidReason(name)
            errors.append(.invalidListName(reason: reason))
            return ValidationResult.failure(errors: errors)
        }
        
        // Validação de conteúdo
        if items.isEmpty {
            warnings.append("Lista está vazia")
            suggestions.append("Adicione pelo menos um produto")
        }
        
        // ✅ INTEGRAÇÃO StringExtensions - Sugestão de formatação
        let normalized = name.normalizedProductName
        if normalized != name {
            suggestions.append("Sugestão de nome: '\(normalized)'")
        }
        
        return ValidationResult.success(warnings: warnings, suggestions: suggestions)
    }
    
    /// Valida nome de lista
    ///
    /// - Parameter name: Nome a validar
    /// - Returns: Bool indicando validade
    /// - Integration: ✅ StringExtensions (.isValidListName)
    public static func isValidListName(_ name: String) -> Bool {
        return name.isValidListName
    }
    
    /// Determina razão para nome de lista inválido
    ///
    /// - Parameter name: Nome a analisar
    /// - Returns: String com razão específica
    /// - Integration: ✅ Constants (BusinessRules)
    private static func determineListNameInvalidReason(_ name: String) -> String {
        let trimmed = name.trimmedAndCleaned
        
        if trimmed.isEmpty {
            return "Nome da lista não pode estar vazio"
        }
        
        if trimmed.count < BusinessRules.minListNameLength {
            return "Nome deve ter pelo menos \(BusinessRules.minListNameLength) caractere"
        }
        
        if trimmed.count > BusinessRules.maxListNameLength {
            return "Nome não pode exceder \(BusinessRules.maxListNameLength) caracteres"
        }
        
        return "Nome tem formato inválido"
    }
}

// MARK: - Price Validator

/// Validador especializado para preços com múltiplas fontes
///
/// Valida preços vindos de diferentes métodos de captura com contexto específico.
public final class PriceValidator: @unchecked Sendable {
    
    /// Validação de preço com contexto de fonte
    ///
    /// - Parameters:
    ///   - price: Preço a validar
    ///   - source: Fonte do preço (OCR, Voice, Manual)
    ///   - confidence: Nível de confiança (0.0-1.0)
    /// - Returns: ValidationResult com validações específicas da fonte
    /// - Integration: ✅ DoubleExtensions, CaptureMethod
    public static func validate(price: Double, source: CaptureMethod, confidence: Double = 1.0) -> ValidationResult {
        // ✅ USA ProductValidator.validatePrice base
        let baseValidation = ProductValidator.validatePrice(price, captureMethod: source)
        
        guard baseValidation.isValid else {
            return baseValidation
        }
        
        var warnings = baseValidation.warnings
        var suggestions = baseValidation.suggestions
        
        // ✅ INTEGRAÇÃO CaptureMethod - Validações específicas por fonte
        switch source {
        case .scanner:
            if confidence < 0.8 {
                warnings.append("Confiança OCR baixa (\(String(format: "%.1f", confidence * 100))%)")
                suggestions.append("Confirme o preço manualmente")
            }
            
        case .voice:
            if confidence < 0.7 {
                warnings.append("Confiança de voz baixa (\(String(format: "%.1f", confidence * 100))%)")
                suggestions.append("Repita o preço mais claramente")
            }
            
        case .manual:
            // ✅ USA DoubleExtensions.roundedToEuro
            let rounded = price.roundedToEuro
            if rounded != price {
                suggestions.append("Preço será arredondado para \(rounded.asCurrency)")
            }
        }
        
        return ValidationResult.success(warnings: warnings, suggestions: suggestions)
    }
    
    /// Validação rápida de string de preço
    ///
    /// - Parameter priceString: String no formato português
    /// - Returns: Bool indicando se é válida
    /// - Integration: ✅ StringExtensions (.extractPortuguesePrice)
    public static func isValidPriceString(_ priceString: String) -> Bool {
        return priceString.extractPortuguesePrice() != nil
    }
}

// MARK: - Comprehensive Validator

/// Validador principal que combina todos os validadores específicos
///
/// Ponto de entrada único para validações complexas que envolvem múltiplos componentes.
public final class CadaEuroValidator: @unchecked Sendable {
    
    /// Validação completa de produto com todos os aspectos
    ///
    /// - Parameters:
    ///   - name: Nome do produto
    ///   - price: Preço do produto
    ///   - quantity: Quantidade
    ///   - captureMethod: Método de captura
    ///   - confidence: Nível de confiança dos dados
    /// - Returns: ValidationResult abrangente
    /// - Integration: ✅ Todas as fundações da Fase 1
    public static func validateProduct(
        name: String,
        price: Double,
        quantity: Int = 1,
        captureMethod: CaptureMethod,
        confidence: Double = 1.0
    ) -> ValidationResult {
        
        // Combina validações de diferentes validadores
        let productValidation = ProductValidator.validate(
            name: name,
            price: price,
            quantity: quantity,
            captureMethod: captureMethod
        )
        
        let priceValidation = PriceValidator.validate(
            price: price,
            source: captureMethod,
            confidence: confidence
        )
        
        // Combina resultados
        var allErrors = productValidation.errors
        allErrors.append(contentsOf: priceValidation.errors)
        
        var allWarnings = productValidation.warnings
        allWarnings.append(contentsOf: priceValidation.warnings)
        
        var allSuggestions = productValidation.suggestions
        allSuggestions.append(contentsOf: priceValidation.suggestions)
        
        // Remove duplicatas
        let uniqueWarnings = Array(Set(allWarnings))
        let uniqueSuggestions = Array(Set(allSuggestions))
        
        return allErrors.isEmpty
            ? ValidationResult.success(warnings: uniqueWarnings, suggestions: uniqueSuggestions)
            : ValidationResult.failure(errors: allErrors, warnings: uniqueWarnings)
    }
    
    /// Validação de entrada de texto livre (OCR/Voice)
    ///
    /// - Parameters:
    ///   - text: Texto capturado
    ///   - method: Método de captura
    /// - Returns: ValidationResult com produto extraído
    /// - Integration: ✅ StringExtensions (.extractProductAndPrice)
    public static func validateTextInput(_ text: String, method: CaptureMethod) -> ValidationResult {
        // ✅ USA StringExtensions.extractProductAndPrice
        let (productName, extractedPrice) = text.extractProductAndPrice()
        
        if productName.isEmpty {
            let error = ValidationError.invalidProductName(reason: "Não foi possível extrair nome do produto")
            return ValidationResult.failure(error: error)
        }
        
        let price = extractedPrice ?? 0.0
        
        return validateProduct(
            name: productName,
            price: price,
            captureMethod: method,
            confidence: text.textConfidenceScore
        )
    }
}

// MARK: - Validation Utilities

/// Extensões utilitárias para integração com componentes existentes
public extension ValidationResult {
    
    /// Converte para formato de erro throw
    ///
    /// - Throws: ValidationError se inválido
    func throwIfInvalid() throws {
        guard isValid else {
            if errors.count == 1 {
                throw errors.first!
            } else {
                throw ValidationError.multipleErrors(errors)
            }
        }
    }
    
    /// Primeira mensagem de erro ou warning
    var primaryMessage: String? {
        return errors.first?.errorDescription ?? warnings.first
    }
    
    /// Todas as mensagens combinadas
    var allMessages: [String] {
        var messages: [String] = []
        messages.append(contentsOf: errors.compactMap { $0.errorDescription })
        messages.append(contentsOf: warnings)
        messages.append(contentsOf: suggestions)
        return messages
    }
}

// MARK: - SwiftUI Integration Helpers

#if canImport(SwiftUI)
import SwiftUI

/// Extensões para uso em SwiftUI
public extension ValidationResult {
    
    /// Cor apropriada para status de validação
    var statusColor: Color {
        if !isValid {
            return .red
        } else if !warnings.isEmpty {
            return .orange
        } else {
            return .green
        }
    }
    
    /// Ícone SF Symbol para status
    var statusIcon: String {
        if !isValid {
            return "exclamationmark.triangle.fill"
        } else if !warnings.isEmpty {
            return "exclamationmark.triangle"
        } else {
            return "checkmark.circle.fill"
        }
    }
}
#endif

// MARK: - Debug Helpers

#if DEBUG
/// Extensões para debugging e desenvolvimento
public extension ValidationResult {
    
    /// Informações detalhadas para debug
    var debugDescription: String {
        var parts: [String] = []
        parts.append("Valid: \(isValid)")
        
        if !errors.isEmpty {
            parts.append("Errors: \(errors.count)")
            for error in errors {
                parts.append("  - \(error.errorDescription ?? "Unknown error")")
            }
        }
        
        if !warnings.isEmpty {
            parts.append("Warnings: \(warnings.count)")
            for warning in warnings {
                parts.append("  - \(warning)")
            }
        }
        
        if !suggestions.isEmpty {
            parts.append("Suggestions: \(suggestions.count)")
            for suggestion in suggestions {
                parts.append("  - \(suggestion)")
            }
        }
        
        return parts.joined(separator: "\n")
    }
    
    /// Log detalhado para console
    func logDebugInfo() {
        print("🔍 ValidationResult Debug:")
        print(debugDescription)
    }
}
#endif
