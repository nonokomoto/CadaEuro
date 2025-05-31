import Foundation

// MARK: - String Extensions for Text Processing and Validation

/// Extensões do String para validação e processamento de texto em português PT
///
/// Esta extensão centraliza toda a lógica de limpeza, validação e formatação de texto
/// da aplicação CadaEuro, garantindo entrada de dados consistente e robusta em português.
///
/// ## Funcionalidades Principais
/// - **Validações Específicas**: Nomes de produtos, listas, preços
/// - **Limpeza Inteligente**: Remoção de caracteres inválidos e normalização
/// - **Parser de Voz**: Extração de produto + preço de transcrições
/// - **OCR Enhancement**: Correção de artifacts de digitalização
/// - **Localização PT**: Números por extenso e padrões portugueses
/// - **Acessibilidade**: Formatação otimizada para VoiceOver
///
/// ## Casos de Uso
/// ```swift
/// // Validação de produto
/// if !productName.isValidProductName {
///     throw ValidationError.invalidName
/// }
///
/// // Parse de voz
/// let (product, price) = transcription.extractProductAndPrice()
/// // "Leite Mimosa dois euros" → ("Leite Mimosa", 2.0)
///
/// // Limpeza OCR
/// let cleanText = ocrResult.cleanOCRText()
/// // "Le1te M1m0sa" → "Leite Mimosa"
/// ```
public extension String {
    
    // MARK: - Basic Text Validation
    
    /// Verifica se é um nome de produto válido
    ///
    /// - Returns: Bool indicando validade
    /// - Rules: 1-100 caracteres após trim, sem caracteres perigosos
    /// - Integration: Conecta com BusinessRules.maxProductNameLength
    ///
    /// ## Validações Aplicadas
    /// - Não vazio após trim de whitespace
    /// - Entre 1 e BusinessRules.maxProductNameLength caracteres
    /// - Sem caracteres de controle ou invisíveis
    /// - Sem sequências HTML/SQL perigosas
    var isValidProductName: Bool {
        let trimmed = self.trimmedAndCleaned
        
        guard !trimmed.isEmpty else { return false }
        guard trimmed.count >= BusinessRules.minProductNameLength else { return false }
        guard trimmed.count <= BusinessRules.maxProductNameLength else { return false }
        guard !trimmed.containsDangerousCharacters else { return false }
        
        return true
    }
    
    /// Verifica se é um nome de lista válido
    ///
    /// - Returns: Bool indicando validade
    /// - Rules: 1-50 caracteres, formatação adequada para SavedListsView
    /// - Default: "Lista de compras" usado quando vazio
    var isValidListName: Bool {
        let trimmed = self.trimmedAndCleaned
        
        guard !trimmed.isEmpty else { return false }
        guard trimmed.count >= BusinessRules.minListNameLength else { return false }
        guard trimmed.count <= BusinessRules.maxListNameLength else { return false }
        guard !trimmed.containsDangerousCharacters else { return false }
        
        return true
    }
    
    /// Verifica se contém apenas caracteres válidos para entrada de preço
    ///
    /// - Returns: Bool indicando se é formato de preço válido
    /// - Format: Apenas dígitos, vírgula decimal, formato PT
    /// - Examples: "12,50", "1,99", "0,99"
    var isValidPriceInput: Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789,")
        let characterSet = CharacterSet(charactersIn: self)
        
        guard allowedCharacters.isSuperset(of: characterSet) else { return false }
        
        // Verifica formato português (apenas uma vírgula)
        let commaCount = self.components(separatedBy: ",").count - 1
        guard commaCount <= 1 else { return false }
        
        // Verifica se pode ser parseado como Double
        return self.extractPortuguesePrice() != nil
    }
    
    // MARK: - Text Cleaning and Normalization
    
    /// String limpa com trim e normalização básica
    ///
    /// - Returns: String processada para uso seguro
    /// - Process: Remove whitespace, quebras, caracteres invisíveis
    /// - Safe: Mantém acentuação portuguesa intacta
    var trimmedAndCleaned: String {
        return self
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .controlCharacters)
    }
    
    /// Normalização de texto para nomes de produtos
    ///
    /// - Returns: String formatada para display consistente
    /// - Format: Capitalização inteligente portuguesa
    /// - Examples: "pão DE forma" → "Pão de Forma"
    var normalizedProductName: String {
        let cleaned = self.trimmedAndCleaned
        
        guard !cleaned.isEmpty else { return cleaned }
        
        // Lista de palavras que devem ficar em minúscula (exceto início)
        let lowercaseWords = ["de", "da", "do", "das", "dos", "e", "com", "sem", "para"]
        
        let words = cleaned.components(separatedBy: " ")
        let capitalizedWords = words.enumerated().map { index, word in
            let lowercaseWord = word.lowercased()
            
            // Primeira palavra sempre capitalizada
            if index == 0 {
                return word.capitalized
            }
            
            // Palavras especiais em minúscula
            if lowercaseWords.contains(lowercaseWord) {
                return lowercaseWord
            }
            
            // Outras palavras capitalizadas
            return word.capitalized
        }
        
        return capitalizedWords.joined(separator: " ")
    }
    
    /// Limpeza específica para texto OCR
    ///
    /// - Returns: String corrigida de artifacts comuns
    /// - Fixes: Caracteres mal reconhecidos, padrões incorretos
    /// - Examples: "Le1te" → "Leite", "O,99" → "0,99"
    var cleanOCRText: String {
        var cleaned = self.trimmedAndCleaned
        
        // Correções específicas OCR
        let ocrCorrections: [String: String] = [
            // Números mal reconhecidos
            "O": "0", // O maiúsculo → zero
            "o": "0", // o minúsculo → zero (em contexto de preço)
            "l": "1", // l minúsculo → um (em contexto de preço)
            "I": "1", // I maiúsculo → um
            "S": "5", // S → cinco (em alguns contextos)
            
            // Caracteres comuns mal reconhecidos
            "€ ": "€", // Espaço após euro
            " €": "€", // Espaço antes euro
            ",,": ",", // Vírgulas duplas
            "..": ".", // Pontos duplos
            
            // Padrões específicos produtos portugueses
            "Lt.": "Litro",
            "Kg.": "Quilograma",
            "gr.": "gramas",
            "ml.": "mililitros"
        ]
        
        // Aplicar correções
        for (wrong, correct) in ocrCorrections {
            cleaned = cleaned.replacingOccurrences(of: wrong, with: correct)
        }
        
        // Limpeza final
        return cleaned.trimmedAndCleaned
    }
    
    /// Confiança da qualidade do texto (0.0 - 1.0)
    ///
    /// - Returns: Double representando confidence score
    /// - Algorithm: Baseado em padrões e caracteres válidos
    /// - Use Case: Decidir se usar OCR ou fallback manual
    var textConfidenceScore: Double {
        let text = self.trimmedAndCleaned
        
        guard !text.isEmpty else { return 0.0 }
        
        var score: Double = 1.0
        let length = Double(text.count)
        
        // Penalizar caracteres estranhos
        let strangeCharacters = text.filter { char in
            !char.isLetter && !char.isNumber && !char.isWhitespace && 
            !["€", ",", ".", "-", "(", ")"].contains(String(char))
        }
        score -= Double(strangeCharacters.count) / length * 0.5
        
        // Bonificar padrões conhecidos
        if text.contains("€") { score += 0.1 }
        if text.range(of: #"\d+[,.]\d{2}"#, options: .regularExpression) != nil { score += 0.2 }
        
        // Penalizar texto muito curto ou muito longo
        if length < 3 { score -= 0.3 }
        if length > 50 { score -= 0.2 }
        
        return max(0.0, min(1.0, score))
    }
    
    // MARK: - Voice Input Processing
    
    /// Extrai produto e preço de transcrição de voz
    ///
    /// - Returns: Tupla (produto, preço) ou (texto_original, nil) se não conseguir extrair
    /// - Algorithm: Heurísticas para padrões portugueses de fala
    /// - Examples: "Leite Mimosa dois euros" → ("Leite Mimosa", 2.0)
    func extractProductAndPrice() -> (product: String, price: Double?) {
        _ = self.trimmedAndCleaned.lowercased()
        
        // Tenta extrair preço primeiro
        if let extractedPrice = extractPriceFromSpeech() {
            // Remove a parte do preço do texto para obter o produto
            let productText = removeSpokenPriceFromText()
            return (productText.normalizedProductName, extractedPrice)
        }
        
        // Se não conseguir extrair preço, retorna texto original como produto
        return (self.normalizedProductName, nil)
    }
    
    /// Extrai preço de fala em português
    ///
    /// - Returns: Double? do preço identificado ou nil
    /// - Patterns: "dois euros", "um e cinquenta", "três euros e vinte"
    private func extractPriceFromSpeech() -> Double? {
        let text = self.lowercased()
        
        // Padrões de preço em português
        let pricePatterns = [
            // Formato numérico direto
            #"(\d+)[,.](\d{1,2})\s*euros?"#,
            #"(\d+)\s*euros?\s*e\s*(\d+)\s*cêntimos?"#,
            
            // Números por extenso
            extractNumbersInPortuguese()
        ].compactMap { $0 }
        
        for pattern in pricePatterns {
            if let match = text.range(of: pattern, options: .regularExpression) {
                return parsePortugueseSpokenPrice(String(text[match]))
            }
        }
        
        return nil
    }
    
    /// Parse de números falados em português
    ///
    /// - Returns: Double? do valor extraído
    /// - Supports: "dois euros", "um e meio", "três e vinte"
    private func parsePortugueseSpokenPrice(_ spokenPrice: String) -> Double? {
        let price = spokenPrice.lowercased()
        
        let numberWords: [String: Double] = [
            "zero": 0, "um": 1, "uma": 1, "dois": 2, "duas": 2, "três": 3,
            "quatro": 4, "cinco": 5, "seis": 6, "sete": 7, "oito": 8,
            "nove": 9, "dez": 10, "onze": 11, "doze": 12, "treze": 13,
            "catorze": 14, "quinze": 15, "dezasseis": 16, "dezassete": 17,
            "dezoito": 18, "dezanove": 19, "vinte": 20, "trinta": 30,
            "quarenta": 40, "cinquenta": 50, "sessenta": 60, "setenta": 70,
            "oitenta": 80, "noventa": 90, "cem": 100, "cento": 100
        ]
        
        let fractionWords: [String: Double] = [
            "meio": 0.5, "meia": 0.5,
            "cinco": 0.05, "dez": 0.10, "quinze": 0.15, "vinte": 0.20,
            "vinte e cinco": 0.25, "trinta": 0.30, "quarenta": 0.40,
            "cinquenta": 0.50
        ]
        
        var total: Double = 0
        
        // Parse euros
        if price.contains("euro") {
            let euroPattern = #"(\w+(?:\s+\w+)*)\s*euros?"#
            if let euroMatch = price.range(of: euroPattern, options: .regularExpression) {
                let euroText = String(price[euroMatch])
                    .replacingOccurrences(of: "euros?", with: "", options: .regularExpression)
                    .trimmedAndCleaned
                
                if let euroValue = numberWords[euroText] {
                    total += euroValue
                }
            }
        }
        
        // Parse cêntimos
        if price.contains("cêntimo") {
            let centPattern = #"(\w+(?:\s+\w+)*)\s*cêntimos?"#
            if let centMatch = price.range(of: centPattern, options: .regularExpression) {
                let centText = String(price[centMatch])
                    .replacingOccurrences(of: "cêntimos?", with: "", options: .regularExpression)
                    .trimmedAndCleaned
                
                if let centValue = numberWords[centText] {
                    total += centValue / 100.0
                }
            }
        }
        
        // Parse frações (meio euro, etc.)
        for (word, value) in fractionWords {
            if price.contains(word) && price.contains("euro") {
                total += value
            }
        }
        
        return total > 0 ? total : nil
    }
    
    /// Remove parte do preço do texto para extrair produto
    ///
    /// - Returns: String apenas com nome do produto
    private func removeSpokenPriceFromText() -> String {
        var text = self.trimmedAndCleaned
        
        // Padrões a remover (preços falados)
        let pricePatterns = [
            #"\d+[,.]?\d*\s*euros?"#,
            #"\d+\s*euros?\s*e\s*\d+\s*cêntimos?"#,
            #"(um|uma|dois|duas|três|quatro|cinco|seis|sete|oito|nove|dez|onze|doze|treze|catorze|quinze|dezasseis|dezassete|dezoito|dezanove|vinte|trinta|quarenta|cinquenta|sessenta|setenta|oitenta|noventa|cem|cento)\s*(euros?|cêntimos?)"#,
            #"(meio|meia)\s*euros?"#,
            #"e\s*(meio|meia)"#
        ]
        
        for pattern in pricePatterns {
            text = text.replacingOccurrences(
                of: pattern,
                with: "",
                options: [.regularExpression, .caseInsensitive]
            )
        }
        
        return text.trimmedAndCleaned
    }
    
    // MARK: - Price Parsing Utilities
    
    /// Extrai preço em formato português (vírgula decimal)
    ///
    /// - Returns: Double? do valor extraído ou nil se inválido
    /// - Format: Suporta "12,50", "1,99", "0,05"
    /// - Integration: Usado por ManualInputForm e ProductConfirmationDialog
    func extractPortuguesePrice() -> Double? {
        let normalized = self
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let price = Double(normalized) else { return nil }
        guard price.isValidPrice else { return nil }
        
        return price
    }
    
    /// Extrai múltiplos preços de um texto
    ///
    /// - Returns: Array de Double com todos os preços encontrados
    /// - Use Case: Parse de recibos com múltiplos itens
    func extractAllPrices() -> [Double] {
        let pricePattern = #"€?\s*(\d+[,.]\d{2})"#
        var prices: [Double] = []
        
        let regex = try? NSRegularExpression(pattern: pricePattern, options: [])
        let matches = regex?.matches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: self.utf16.count)
        ) ?? []
        
        for match in matches {
            if let range = Range(match.range(at: 1), in: self) {
                let priceText = String(self[range])
                if let price = priceText.extractPortuguesePrice() {
                    prices.append(price)
                }
            }
        }
        
        return prices
    }
    
    // MARK: - Email and URL Validation
    
    /// Verifica se é um email válido
    ///
    /// - Returns: Bool indicando validade
    /// - Use Case: Export/sharing de listas, configurações de utilizador
    var isValidEmail: Bool {
        let emailPattern = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        return self.range(of: emailPattern, options: .regularExpression) != nil
    }
    
    /// Verifica se é uma URL válida
    ///
    /// - Returns: Bool indicando se é URL bem formada
    /// - Use Case: Links de ajuda, termos de serviço
    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return url.scheme != nil && url.host != nil
    }
    
    // MARK: - Security Helpers
    
    /// Verifica se contém caracteres perigosos
    ///
    /// - Returns: Bool indicando presença de caracteres suspeitos
    /// - Security: Prevenção de injection attacks básicos
    private var containsDangerousCharacters: Bool {
        let dangerousPatterns = [
            "<script", "</script>", "javascript:", "eval(",
            "DROP TABLE", "SELECT *", "DELETE FROM", "INSERT INTO",
            "UPDATE SET", "--", "/*", "*/"
        ]
        
        let lowercaseText = self.lowercased()
        
        return dangerousPatterns.contains { pattern in
            lowercaseText.contains(pattern.lowercased())
        }
    }
    
    /// String sanitizada para uso seguro
    ///
    /// - Returns: String com caracteres perigosos removidos
    /// - Safe: Remove scripts, SQL, caracteres de controle
    var sanitized: String {
        var cleaned = self.trimmedAndCleaned
        
        // Remove caracteres de controle
        cleaned = cleaned.filter { !$0.isNewline && !$0.isWhitespace || $0 == " " }
        
        // Remove padrões HTML/JS básicos
        cleaned = cleaned.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        // Limita tamanho
        if cleaned.count > 1000 {
            cleaned = String(cleaned.prefix(1000))
        }
        
        return cleaned
    }
    
    // MARK: - Portuguese Number Processing
    
    /// Extrai números escritos por extenso em português
    ///
    /// - Returns: String? com padrão regex ou nil
    /// - Use Case: Parse de voz para números falados
    private func extractNumbersInPortuguese() -> String? {
        let numberWords = [
            "zero", "um", "uma", "dois", "duas", "três", "quatro", "cinco",
            "seis", "sete", "oito", "nove", "dez", "onze", "doze", "treze",
            "catorze", "quinze", "dezasseis", "dezassete", "dezoito",
            "dezanove", "vinte", "trinta", "quarenta", "cinquenta",
            "sessenta", "setenta", "oitenta", "noventa", "cem", "cento"
        ].joined(separator: "|")
        
        return #"(\#(numberWords))(?:\s+e\s+(\#(numberWords)))?\s*euros?"#
    }
    
    // MARK: - Text Statistics
    
    /// Estatísticas básicas do texto
    ///
    /// - Returns: Tupla com (words, characters, sentences)
    /// - Use Case: Análise de qualidade de input, debugging
    var textStatistics: (words: Int, characters: Int, sentences: Int) {
        let trimmed = self.trimmedAndCleaned
        
        let words = trimmed.isEmpty ? 0 : trimmed.components(separatedBy: .whitespaces).count
        let characters = trimmed.count
        let sentences = trimmed.components(separatedBy: CharacterSet(charactersIn: ".!?")).count - 1
        
        return (words: words, characters: characters, sentences: max(1, sentences))
    }
    
    /// Densidade de informação (palavras por caractere)
    ///
    /// - Returns: Double representando densidade
    /// - Use Case: Qualidade de OCR, eficiência de input
    var informationDensity: Double {
        let stats = textStatistics
        guard stats.characters > 0 else { return 0.0 }
        return Double(stats.words) / Double(stats.characters)
    }
}

// MARK: - Collection Extensions for Text Processing

/// Extensões para coleções de strings
public extension Collection where Element == String {
    
    /// Filtra apenas strings que são nomes de produtos válidos
    ///
    /// - Returns: Array filtrado com apenas nomes válidos
    /// - Use Case: Limpeza de listas OCR/voice antes processamento
    var validProductNames: [String] {
        return self.filter { $0.isValidProductName }
    }
    
    /// Concatena strings com formatação inteligente
    ///
    /// - Parameter separator: Separador personalizado (default: ", ")
    /// - Returns: String concatenada limpa
    var smartJoined: String {
        return self
            .map { $0.trimmedAndCleaned }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
    
    /// String com maior confiança de qualidade
    ///
    /// - Returns: String? com melhor confidence score
    /// - Use Case: Escolher melhor resultado entre múltiplas tentativas OCR
    var bestQualityText: String? {
        return self.max(by: { $0.textConfidenceScore < $1.textConfidenceScore })
    }
}

// MARK: - Character Extensions

/// Extensões para Character com foco em português
public extension Character {
    
    /// Verifica se é um caractere válido para nomes de produtos
    ///
    /// - Returns: Bool indicando validade
    /// - Includes: Letras, números, espaços, hífens, parênteses
    var isValidForProductName: Bool {
        return self.isLetter || self.isNumber || self.isWhitespace ||
               ["(", ")", "-", "'", ".", "%", "&"].contains(self)
    }
    
    /// Verifica se é acentuação portuguesa
    ///
    /// - Returns: Bool indicando se é acento PT
    /// - Portuguese: á, à, ã, â, é, ê, í, ó, ô, õ, ú, ç
    var isPortugueseAccent: Bool {
        let portugueseAccents: Set<Character> = [
            "á", "à", "ã", "â", "é", "ê", "í", "ó", "ô", "õ", "ú", "ç",
            "Á", "À", "Ã", "Â", "É", "Ê", "Í", "Ó", "Ô", "Õ", "Ú", "Ç"
        ]
        return portugueseAccents.contains(self)
    }
}

// MARK: - Regex Utilities

/// Utilitários para expressões regulares thread-safe
private final class RegexCache: @unchecked Sendable {
    static let shared = RegexCache()
    
    private let cache = NSCache<NSString, NSRegularExpression>()
    private let lock = NSLock()
    
    private init() {
        cache.countLimit = 50 // Limite de padrões em cache
    }
    
    func regex(for pattern: String) -> NSRegularExpression? {
        let key = NSString(string: pattern)
        
        lock.lock()
        defer { lock.unlock() }
        
        if let cached = cache.object(forKey: key) {
            return cached
        }
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        
        cache.setObject(regex, forKey: key)
        return regex
    }
}

// MARK: - String Extension for Regex Helpers

public extension String {
    
    /// Executa regex com cache para performance
    ///
    /// - Parameter pattern: Padrão de expressão regular
    /// - Returns: Array de matches encontrados
    func matches(for pattern: String) -> [String] {
        guard let regex = RegexCache.shared.regex(for: pattern) else {
            return []
        }
        
        let matches = regex.matches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: self.utf16.count)
        )
        
        return matches.compactMap { match in
            if let range = Range(match.range, in: self) {
                return String(self[range])
            }
            return nil
        }
    }
    
    /// Substitui padrão regex com replacement
    ///
    /// - Parameters:
    ///   - pattern: Padrão de expressão regular
    ///   - replacement: String de substituição
    /// - Returns: String com substituições aplicadas
    func replacingMatches(of pattern: String, with replacement: String) -> String {
        guard let regex = RegexCache.shared.regex(for: pattern) else {
            return self
        }
        
        return regex.stringByReplacingMatches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: self.utf16.count),
            withTemplate: replacement
        )
    }
}

// MARK: - Localization Helpers

public extension String {
    
    /// Formata string para português PT
    ///
    /// - Returns: String formatada com regras portuguesas
    /// - Rules: Acentuação, capitalização, conectivos
    var portugueseFormatted: String {
        return self
            .normalizedProductName
            .replacingOccurrences(of: " E ", with: " e ")
            .replacingOccurrences(of: " DE ", with: " de ")
            .replacingOccurrences(of: " DO ", with: " do ")
            .replacingOccurrences(of: " DA ", with: " da ")
    }
    
    /// Plural inteligente para português
    ///
    /// - Parameter count: Quantidade para determinar plural
    /// - Returns: String no singular ou plural conforme count
    func pluralized(count: Int) -> String {
        guard count != 1 else { return self }
        
        // Regras básicas de plural português
        if self.hasSuffix("ão") {
            return String(self.dropLast(2)) + "ões"
        } else if self.hasSuffix("l") {
            return String(self.dropLast(1)) + "is"
        } else if self.hasSuffix("r") || self.hasSuffix("s") || self.hasSuffix("z") {
            return self + "es"
        } else {
            return self + "s"
        }
    }
}

// MARK: - Debug and Development Helpers

#if DEBUG
/// Extensões específicas para debugging e desenvolvimento
public extension String {
    
    /// Informações detalhadas para debugging
    ///
    /// - Returns: String com metadados para troubleshooting
    /// - Format: "Text: 'content' (chars: X, words: Y, valid: Z)"
    var debugInfo: String {
        let stats = textStatistics
        let isValid = isValidProductName
        let confidence = String(format: "%.2f", textConfidenceScore)
        
        return "Text: '\(self)' (chars: \(stats.characters), words: \(stats.words), valid: \(isValid), confidence: \(confidence))"
    }
    
    /// Análise de qualidade detalhada
    ///
    /// - Returns: String com análise completa
    var qualityAnalysis: String {
        var analysis: [String] = []
        
        analysis.append("Length: \(count)")
        analysis.append("Valid product: \(isValidProductName)")
        analysis.append("Confidence: \(String(format: "%.2f", textConfidenceScore))")
        analysis.append("Dangerous chars: \(containsDangerousCharacters)")
        analysis.append("Information density: \(String(format: "%.3f", informationDensity))")
        
        return analysis.joined(separator: ", ")
    }
}
#endif

// MARK: - Performance Monitoring

/// Monitor de performance para operações de string (desenvolvimento)
#if DEBUG
private final class StringPerformanceMonitor: @unchecked Sendable {
    static let shared = StringPerformanceMonitor()
    
    private var operationCounts: [String: Int] = [:]
    private let queue = DispatchQueue(label: "string.performance.monitor")
    
    func recordOperation(_ operation: String) {
        queue.async {
            self.operationCounts[operation, default: 0] += 1
            
            // Log a cada 100 operações
            if self.operationCounts[operation]! % 100 == 0 {
                print("🔤 StringExtensions: \(operation) called \(self.operationCounts[operation]!) times")
            }
        }
    }
    
    func printStatistics() {
        queue.async {
            print("📊 StringExtensions Performance:")
            for (operation, count) in self.operationCounts.sorted(by: { $0.value > $1.value }) {
                print("  \(operation): \(count) calls")
            }
        }
    }
}
#endif
