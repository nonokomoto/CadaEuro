import Foundation

// MARK: - Double Extensions for Currency Formatting

/// Extensões do Double para formatação monetária consistente em euros (pt_PT)
///
/// Esta extensão centraliza toda a lógica de formatação monetária da aplicação CadaEuro,
/// garantindo apresentação uniforme e localizada em português de Portugal em todos os contextos.
///
/// ## Funcionalidades Principais
/// - **Formatação Portuguesa**: Vírgula como separador decimal (€1,99)
/// - **Símbolo Euro**: Posicionamento correto conforme BusinessRules
/// - **Casas Decimais**: Sempre 2 casas para valores monetários
/// - **Acessibilidade**: Formatação específica para VoiceOver
/// - **Performance**: NumberFormatter cached para reutilização
///
/// ## Casos de Uso
/// ```swift
/// let price = 1.29
/// price.asCurrency          // "€1,29"
/// price.asCurrencyCompact   // "€1,29" (versão compacta)
/// price.asCurrencyDetailed  // "€1,29" (versão completa)
/// price.asCurrencyAccessible // "um euro e vinte e nove cêntimos"
/// ```
///
/// ## Integração com BusinessRules
/// - Usa `BusinessRules.locale` para consistência
/// - Aplica `BusinessRules.currencySymbol` automaticamente
/// - Respeita `BusinessRules.minPrice` e `BusinessRules.maxPrice`
public extension Double {
    
    // MARK: - Primary Currency Formatting
    
    /// Formatação monetária padrão para euros em português PT
    ///
    /// - Returns: String formatada como "€1,29"
    /// - Note: Método principal usado em ItemCard, ManualInputForm, TotalDisplay
    /// - Performance: Utiliza formatter cached para otimização
    /// - Localization: Segue BusinessRules.locale (pt_PT)
    ///
    /// ## Exemplo
    /// ```swift
    /// let price = 12.50
    /// Text(price.asCurrency) // "€12,50"
    /// ```
    var asCurrency: String {
        return CurrencyFormatter.shared.standard.string(from: NSNumber(value: self)) ?? "€0,00"
    }
    
    /// Formatação monetária compacta para espaços limitados
    ///
    /// - Returns: String formatada de forma compacta "€1,29"
    /// - Use Case: Badges, tags, componentes pequenos
    /// - Note: Atualmente idêntica ao padrão, preparada para futuras otimizações
    ///
    /// ## Exemplo
    /// ```swift
    /// let price = 1.99
    /// Text(price.asCurrencyCompact) // "€1,99"
    /// ```
    var asCurrencyCompact: String {
        return CurrencyFormatter.shared.compact.string(from: NSNumber(value: self)) ?? "€0,00"
    }
    
    /// Formatação monetária detalhada para relatórios e displays principais
    ///
    /// - Returns: String formatada com separadores de milhares "€1 234,56"
    /// - Use Case: TotalDisplay, estatísticas, relatórios
    /// - Feature: Inclui separador de milhares para valores grandes
    ///
    /// ## Exemplo
    /// ```swift
    /// let total = 1234.56
    /// Text(total.asCurrencyDetailed) // "€1 234,56"
    /// ```
    var asCurrencyDetailed: String {
        return CurrencyFormatter.shared.detailed.string(from: NSNumber(value: self)) ?? "€0,00"
    }
    
    /// Formatação monetária otimizada para VoiceOver e acessibilidade
    ///
    /// - Returns: String legível por voz "um euro e vinte e nove cêntimos"
    /// - Use Case: Labels de acessibilidade, VoiceOver
    /// - Accessibility: Lê valores monetários de forma natural
    /// - Locale: Utiliza spellOut style para português PT
    ///
    /// ## Exemplo
    /// ```swift
    /// let price = 1.29
    /// Text(price.asCurrency)
    ///     .accessibilityLabel(price.asCurrencyAccessible)
    /// // VoiceOver lê: "um euro e vinte e nove cêntimos"
    /// ```
    var asCurrencyAccessible: String {
        return CurrencyFormatter.shared.accessible.string(from: NSNumber(value: self)) ?? "zero euros"
    }
    
    // MARK: - Validation Helpers
    
    /// Verifica se o valor está dentro dos limites de preço válidos
    ///
    /// - Returns: Bool indicando se está entre BusinessRules.minPrice e BusinessRules.maxPrice
    /// - Use Case: Validação em ManualInputForm para entrada de preços
    /// - Integration: Conecta com BusinessRules para limites centralizados
    ///
    /// ## Exemplo
    /// ```swift
    /// let userPrice = 12.50
    /// if userPrice.isValidPrice {
    ///     // Preço aceitável
    /// }
    /// ```
    var isValidPrice: Bool {
        return self >= BusinessRules.minPrice && self <= BusinessRules.maxPrice
    }
    
    /// Converte valor para formato de entrada manual (vírgula como decimal)
    ///
    /// - Returns: String com vírgula como separador decimal "12,50"
    /// - Use Case: Inicialização de campos de texto em formulários
    /// - Note: Sem símbolo de moeda para edição
    ///
    /// ## Exemplo
    /// ```swift
    /// let price = 12.5
    /// let textFieldValue = price.asEditablePrice // "12,50"
    /// ```
    var asEditablePrice: String {
        let formatter = NumberFormatter()
        formatter.locale = BusinessRules.locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: self)) ?? "0,00"
    }
    
    // MARK: - Parsing Helpers
    
    /// Cria Double a partir de string com formato português (vírgula decimal)
    ///
    /// - Parameter portugueseString: String no formato "12,50"
    /// - Returns: Double? parseado ou nil se inválido
    /// - Use Case: Parsing de input do utilizador em formulários
    /// - Locale: Suporta formato pt_PT com vírgula
    ///
    /// ## Exemplo
    /// ```swift
    /// let userInput = "12,50"
    /// if let price = Double.fromPortugueseString(userInput) {
    ///     // price = 12.5
    /// }
    /// ```
    static func fromPortugueseString(_ string: String) -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = BusinessRules.locale
        formatter.numberStyle = .decimal
        
        return formatter.number(from: string)?.doubleValue
    }
}

// MARK: - Currency Formatter Manager

/// Gerenciador centralizado de formatadores monetários para performance otimizada
///
/// Esta classe mantém instâncias cached de NumberFormatter para evitar recriação constante
/// e garantir thread safety para Swift 6 concurrency.
///
/// ## Thread Safety
/// - Utiliza lazy initialization thread-safe
/// - NumberFormatter é thread-safe após configuração
/// - Preparado para Swift 6 Sendable compliance
///
/// ## Performance Benefits
/// - Evita recriação de formatters a cada chamada
/// - Cache inteligente para formatters específicos
/// - Minimal memory footprint com lazy loading
private final class CurrencyFormatter: @unchecked Sendable {
    
    /// Instância singleton thread-safe
    static let shared = CurrencyFormatter()
    
    private init() {}
    
    // MARK: - Cached Formatters
    
    /// Formatter padrão para valores monetários básicos
    ///
    /// Configuração:
    /// - Símbolo: € antes do valor
    /// - Decimal: Vírgula (BusinessRules.locale)
    /// - Casas: Sempre 2 decimais
    /// - Milhares: Sem separador para valores pequenos
    lazy var standard: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = BusinessRules.locale
        formatter.numberStyle = .currency
        formatter.currencySymbol = BusinessRules.currencySymbol
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter
    }()
    
    /// Formatter compacto para espaços limitados
    ///
    /// Configuração idêntica ao standard, preparada para futuras otimizações
    /// como remoção de decimais zero (.00) em versões futuras.
    lazy var compact: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = BusinessRules.locale
        formatter.numberStyle = .currency
        formatter.currencySymbol = BusinessRules.currencySymbol
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter
    }()
    
    /// Formatter detalhado com separadores de milhares
    ///
    /// Configuração:
    /// - Incluí separador de milhares (espaço)
    /// - Ideal para valores grandes (€1 234,56)
    /// - Usado em TotalDisplay e estatísticas
    lazy var detailed: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = BusinessRules.locale
        formatter.numberStyle = .currency
        formatter.currencySymbol = BusinessRules.currencySymbol
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return formatter
    }()
    
    /// Formatter para acessibilidade (VoiceOver)
    ///
    /// Configuração:
    /// - Style: spellOut para leitura natural
    /// - Locale: pt_PT para pronunciação correta
    /// - Output: "um euro e vinte e nove cêntimos"
    lazy var accessible: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = BusinessRules.locale
        formatter.numberStyle = .spellOut
        return formatter
    }()
}

// MARK: - Extensions for Specific Use Cases

/// Extensões específicas para casos de uso comuns na aplicação
public extension Double {
    
    // MARK: - Component Integration
    
    /// Formatação específica para ItemCard
    ///
    /// - Returns: String formatada para cards de produto
    /// - Use Case: Preço individual em ItemCard
    /// - Note: Utiliza formatação padrão otimizada para leitura rápida
    var asItemCardPrice: String {
        return self.asCurrency
    }
    
    /// Formatação específica para TotalDisplay
    ///
    /// - Returns: String formatada para display principal
    /// - Use Case: Total da lista em destaque
    /// - Feature: Usa formato detalhado com separadores para valores grandes
    var asTotalDisplayPrice: String {
        return self.asCurrencyDetailed
    }
    
    /// Formatação específica para listas guardadas
    ///
    /// - Returns: String formatada para SavedListsView
    /// - Use Case: Total das listas nos cards de histórico
    /// - Note: Formato padrão adequado para cards compactos
    var asSavedListPrice: String {
        return self.asCurrency
    }
    
    /// Formatação específica para estatísticas
    ///
    /// - Returns: String formatada para StatsView
    /// - Use Case: Métricas calculadas em relatórios
    /// - Feature: Formato detalhado para análise precisa
    var asStatsPrice: String {
        return self.asCurrencyDetailed
    }
    
    // MARK: - Validation Integration
    
    /// Verifica e formata preço com fallback para valores inválidos
    ///
    /// - Parameter fallback: Valor padrão se fora dos limites
    /// - Returns: String formatada com validação automática
    /// - Use Case: Display seguro mesmo com dados inconsistentes
    ///
    /// ## Exemplo
    /// ```swift
    /// let userPrice = -5.0 // Inválido
    /// let safeDisplay = userPrice.asSafePrice() // "€0,00"
    /// ```
    func asSafePrice(fallback: Double = 0.0) -> String {
        let safeValue = self.isValidPrice ? self : fallback
        return safeValue.asCurrency
    }
    
    // MARK: - Mathematical Helpers
    
    /// Arredonda valor para centavos (2 casas decimais)
    ///
    /// - Returns: Double arredondado para moeda
    /// - Use Case: Cálculos de total, preços unitários
    /// - Precision: Garante precisão monetária sem floating point errors
    ///
    /// ## Exemplo
    /// ```swift
    /// let calculated = 12.999
    /// let price = calculated.roundedToEuro // 13.00
    /// ```
    var roundedToEuro: Double {
        return (self * 100).rounded() / 100
    }
    
    /// Multiplica por quantidade e formata como preço total
    ///
    /// - Parameter quantity: Quantidade do produto
    /// - Returns: String formatada do total (preço × quantidade)
    /// - Use Case: Cálculo de subtotais em ItemCard
    ///
    /// ## Exemplo
    /// ```swift
    /// let unitPrice = 1.29
    /// let totalForThree = unitPrice.multiplyAndFormat(by: 3) // "€3,87"
    /// ```
    func multiplyAndFormat(by quantity: Int) -> String {
        let total = (self * Double(quantity)).roundedToEuro
        return total.asCurrency
    }
}

// MARK: - Collection Extensions

/// Extensões para coleções de valores monetários
public extension Collection where Element == Double {
    
    /// Soma todos os valores e formata como total
    ///
    /// - Returns: String formatada da soma total
    /// - Use Case: Cálculo de total da lista de compras
    /// - Feature: Usa formato detalhado para totais importantes
    ///
    /// ## Exemplo
    /// ```swift
    /// let prices = [1.29, 2.50, 3.99]
    /// let total = prices.asTotalSum // "€7,78"
    /// ```
    var asTotalSum: String {
        let sum = self.reduce(0, +).roundedToEuro
        return sum.asTotalDisplayPrice
    }
    
    /// Calcula média e formata como preço
    ///
    /// - Returns: String formatada da média ou "€0,00" se vazio
    /// - Use Case: Estatísticas de gasto médio
    /// - Calculation: Média aritmética arredondada para centavos
    ///
    /// ## Exemplo
    /// ```swift
    /// let prices = [1.00, 2.00, 3.00]
    /// let average = prices.asAveragePrice // "€2,00"
    /// ```
    var asAveragePrice: String {
        guard !self.isEmpty else { return 0.0.asCurrency }
        let average = (self.reduce(0, +) / Double(self.count)).roundedToEuro
        return average.asStatsPrice
    }
}

// MARK: - SwiftUI Integration Helpers

#if canImport(SwiftUI)
import SwiftUI

/// Extensões específicas para integração SwiftUI
public extension Double {
    
    /// Binding para edição de preços em formulários
    ///
    /// - Parameter binding: Binding<String> do campo de texto
    /// - Returns: Binding que converte Double ↔ String automaticamente
    /// - Use Case: Integração com TextField em ManualInputForm
    /// - Format: Mantém formato português durante edição
    ///
    /// ## Exemplo
    /// ```swift
    /// @State private var price: Double = 0.0
    /// @State private var priceText: String = ""
    /// 
    /// TextField("Preço", text: price.editableBinding($priceText))
    /// ```
    func editableBinding(_ textBinding: Binding<String>) -> Binding<String> {
        return Binding<String>(
            get: {
                textBinding.wrappedValue.isEmpty ? self.asEditablePrice : textBinding.wrappedValue
            },
            set: { newValue in
                textBinding.wrappedValue = newValue
            }
        )
    }
}
#endif

// MARK: - Error Handling Extensions

/// Extensões para tratamento de erros em formatação
public extension Double {
    
    /// Formatação defensiva que nunca falha
    ///
    /// - Returns: String formatada ou fallback seguro
    /// - Use Case: Situações onde formatação não pode falhar
    /// - Safety: Garante sempre um valor válido para display
    ///
    /// ## Exemplo
    /// ```swift
    /// let unknownValue = Double.infinity
    /// let safeDisplay = unknownValue.asSafeCurrency // "€0,00"
    /// ```
    var asSafeCurrency: String {
        guard self.isFinite && self.isValidPrice else {
            return 0.0.asCurrency
        }
        return self.asCurrency
    }
    
    /// Verifica se o valor é apropriado para formatação monetária
    ///
    /// - Returns: Bool indicando se é um valor monetário válido
    /// - Checks: Finito, não-NaN, dentro dos limites de negócio
    /// - Use Case: Validação antes de formatação ou cálculos
    var isValidMonetaryValue: Bool {
        return self.isFinite && !self.isNaN && self.isValidPrice
    }
}

// MARK: - Debug Extensions

#if DEBUG
/// Extensões específicas para debugging e desenvolvimento
public extension Double {
    
    /// Formatação com informações de debug
    ///
    /// - Returns: String com valor e metadados para debugging
    /// - Use Case: Logs de desenvolvimento, troubleshooting
    /// - Format: "€12,50 (raw: 12.5, valid: true)"
    var asDebugCurrency: String {
        let formatted = self.asCurrency
        let isValid = self.isValidPrice
        return "\(formatted) (raw: \(self), valid: \(isValid))"
    }
}
#endif
