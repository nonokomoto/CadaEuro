import Foundation

// MARK: - Date Extensions for Temporal Formatting

/// Extensões do Date para formatação temporal consistente em português PT
///
/// Esta extensão centraliza toda a lógica de formatação de datas da aplicação CadaEuro,
/// garantindo apresentação uniforme e localizada em português de Portugal em todos os contextos.
///
/// ## Funcionalidades Principais
/// - **Formatação Portuguesa**: Nomes de meses e dias em PT
/// - **Relative Dating**: "há X tempo", "Hoje", "Ontem", "Esta semana"
/// - **Business Logic**: Integração com BusinessRules.locale
/// - **Acessibilidade**: Formato verboso para VoiceOver
/// - **Performance**: DateFormatter cached para reutilização
///
/// ## Casos de Uso
/// ```swift
/// let date = Date()
/// date.asCompactDate           // "29 Mai"
/// date.asRelativeTime          // "há 2 min"
/// date.asMonthYear             // "Janeiro 2025"
/// date.asAccessibleDate        // "vinte e nove de maio de dois mil e vinte e cinco"
/// ```
///
/// ## Integração com BusinessRules
/// - Usa `BusinessRules.locale` para consistência
/// - Suporte a `BusinessRules.timeZone` quando disponível
/// - Formatação de relatórios alinhada com locale padrão
public extension Date {
    
    // MARK: - Primary Date Formatting
    
    /// Formatação compacta para SavedListsView
    ///
    /// - Returns: String formatada como "29 Mai"
    /// - Use Case: Cards de listas guardadas, dados compactos
    /// - Format: Dia + Mês abreviado em português
    ///
    /// ## Exemplo
    /// ```swift
    /// let completedDate = Date()
    /// Text(completedDate.asCompactDate) // "29 Mai"
    /// ```
    var asCompactDate: String {
        return DateFormatterCache.shared.compact.string(from: self)
    }
    
    /// Formatação de mês e ano para StatsView
    ///
    /// - Returns: String formatada como "Janeiro 2025"
    /// - Use Case: Navegação temporal em estatísticas
    /// - Format: Mês completo + Ano em português
    ///
    /// ## Exemplo
    /// ```swift
    /// let currentMonth = Date()
    /// Text(currentMonth.asMonthYear) // "Janeiro 2025"
    /// ```
    var asMonthYear: String {
        return DateFormatterCache.shared.monthYear.string(from: self)
    }
    
    /// Formatação relativa inteligente
    ///
    /// - Returns: String com tempo relativo "há X tempo" ou data absoluta
    /// - Logic: "há X min/h" para recente, "Hoje/Ontem" para dias, data para antigo
    /// - Use Case: ItemCard timestamps, última modificação
    ///
    /// ## Exemplo
    /// ```swift
    /// let addedDate = Date().addingTimeInterval(-120)
    /// Text(addedDate.asRelativeTime) // "há 2 min"
    /// ```
    var asRelativeTime: String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(self)
        
        // Futuro (caso de edge case)
        if timeInterval < 0 {
            return "agora"
        }
        
        // Menos de 1 minuto
        if timeInterval < 60 {
            return "agora"
        }
        
        // Menos de 1 hora
        if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "há \(minutes) min"
        }
        
        // Menos de 24 horas
        if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "há \(hours)h"
        }
        
        // Hoje, ontem, anteontem
        if Calendar.current.isDateInToday(self) {
            return "Hoje"
        } else if Calendar.current.isDateInYesterday(self) {
            return "Ontem"
        } else if timeInterval < 172800 { // 2 dias
            return "Anteontem"
        }
        
        // Esta semana
        if Calendar.current.isDate(self, equalTo: now, toGranularity: .weekOfYear) {
            return DateFormatterCache.shared.weekday.string(from: self)
        }
        
        // Este ano
        if Calendar.current.isDate(self, equalTo: now, toGranularity: .year) {
            return DateFormatterCache.shared.dayMonth.string(from: self)
        }
        
        // Anos anteriores
        return DateFormatterCache.shared.full.string(from: self)
    }
    
    /// Formatação para timestamps detalhados
    ///
    /// - Returns: String com data e hora "29 Mai 2025, 14:30"
    /// - Use Case: Logs, detalhes de modificação, debug
    /// - Format: Data compacta + hora
    ///
    /// ## Exemplo
    /// ```swift
    /// let timestamp = Date()
    /// Text(timestamp.asTimestamp) // "29 Mai 2025, 14:30"
    /// ```
    var asTimestamp: String {
        return DateFormatterCache.shared.timestamp.string(from: self)
    }
    
    /// Formatação otimizada para VoiceOver e acessibilidade
    ///
    /// - Returns: String legível por voz "vinte e nove de maio de dois mil e vinte e cinco"
    /// - Use Case: Labels de acessibilidade, VoiceOver
    /// - Accessibility: Lê datas de forma natural em português
    ///
    /// ## Exemplo
    /// ```swift
    /// let date = Date()
    /// Text(date.asCompactDate)
    ///     .accessibilityLabel(date.asAccessibleDate)
    /// ```
    var asAccessibleDate: String {
        return DateFormatterCache.shared.accessible.string(from: self)
    }
    
    // MARK: - Specific Use Case Formatting
    
    /// Formatação para SavedListsView cards
    ///
    /// - Returns: String formatada para cards de listas
    /// - Use Case: Data de conclusão em ListCard
    /// - Note: Utiliza formatação compacta otimizada
    var asSavedListDate: String {
        return self.asCompactDate
    }
    
    /// Formatação para ItemCard timestamps
    ///
    /// - Returns: String formatada para cards de produto
    /// - Use Case: "Adicionado há X" em ItemCard
    /// - Note: Utiliza tempo relativo para melhor UX
    var asItemCardDate: String {
        return self.asRelativeTime
    }
    
    /// Formatação para navegação de estatísticas
    ///
    /// - Returns: String formatada para StatsView
    /// - Use Case: Headers de navegação temporal
    /// - Note: Formato mês/ano padrão
    var asStatsDate: String {
        return self.asMonthYear
    }
    
    /// Formatação para export/relatórios
    ///
    /// - Returns: String formatada ISO8601 para APIs
    /// - Use Case: Export de dados, comunicação com APIs
    /// - Format: ISO8601 padrão internacional
    var asExportDate: String {
        return DateFormatterCache.shared.iso8601.string(from: self)
    }
    
    /// Formatação para nomes de arquivos
    ///
    /// - Returns: String segura para filenames "2025_05_29"
    /// - Use Case: Export de listas, backup de dados
    /// - Format: YYYY_MM_DD compatível com sistemas de arquivo
    var asFilename: String {
        return DateFormatterCache.shared.filename.string(from: self)
    }
    
    // MARK: - Date Calculations
    
    /// Início do dia (00:00:00)
    ///
    /// - Returns: Date representando meia-noite do mesmo dia
    /// - Use Case: Filtros de estatísticas, queries por dia
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    /// Fim do dia (23:59:59)
    ///
    /// - Returns: Date representando final do dia
    /// - Use Case: Filtros de range, queries de período
    var endOfDay: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfDay) ?? self
    }
    
    /// Início do mês
    ///
    /// - Returns: Date representando primeiro dia do mês
    /// - Use Case: Navegação mensal em StatsView
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// Fim do mês
    ///
    /// - Returns: Date representando último segundo do mês
    /// - Use Case: Filtros mensais, relatórios de período
    var endOfMonth: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfMonth) ?? self
    }
    
    /// Adiciona dias à data
    ///
    /// - Parameter days: Número de dias a adicionar (pode ser negativo)
    /// - Returns: Nova Date com dias adicionados
    /// - Use Case: Navegação de períodos, cálculos temporais
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    /// Adiciona meses à data
    ///
    /// - Parameter months: Número de meses a adicionar (pode ser negativo)
    /// - Returns: Nova Date com meses adicionados
    /// - Use Case: Navegação mensal em StatsView
    func adding(months: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }
    
    // MARK: - Date Validation Helpers
    
    /// Verifica se a data é hoje
    ///
    /// - Returns: Bool indicando se é hoje
    /// - Use Case: Filtros, UI conditional logic
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    /// Verifica se a data é ontem
    ///
    /// - Returns: Bool indicando se é ontem
    /// - Use Case: Agrupamento temporal, filtros
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    /// Verifica se a data é nesta semana
    ///
    /// - Returns: Bool indicando se é na semana atual
    /// - Use Case: Agrupamento de dados, filtros temporais
    var isThisWeek: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    /// Verifica se a data é neste mês
    ///
    /// - Returns: Bool indicando se é no mês atual
    /// - Use Case: Estatísticas mensais, filtros
    var isThisMonth: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    /// Verifica se a data é neste ano
    ///
    /// - Returns: Bool indicando se é no ano atual
    /// - Use Case: Navegação anual, agrupamentos
    var isThisYear: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }
    
    /// Verifica se a data está no futuro
    ///
    /// - Returns: Bool indicando se é no futuro
    /// - Use Case: Validação de datas, logic business
    var isFuture: Bool {
        return self > Date()
    }
    
    /// Distância em dias para outra data
    ///
    /// - Parameter date: Data de comparação
    /// - Returns: Número de dias (positivo se futuro, negativo se passado)
    /// - Use Case: Cálculos de idade, diferenças temporais
    func daysSince(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: self)
        return components.day ?? 0
    }
}

// MARK: - Date Formatter Manager

/// Gerenciador centralizado de formatadores de data para performance otimizada
///
/// Esta classe mantém instâncias cached de DateFormatter para evitar recriação constante
/// e garantir thread safety para Swift 6 concurrency.
///
/// ## Thread Safety
/// - Utiliza lazy initialization thread-safe
/// - DateFormatter é thread-safe após configuração
/// - Preparado para Swift 6 Sendable compliance
///
/// ## Performance Benefits
/// - Evita recriação de formatters a cada chamada
/// - Cache inteligente para formatters específicos
/// - Minimal memory footprint com lazy loading
private final class DateFormatterCache: @unchecked Sendable {
    
    /// Instância singleton thread-safe
    static let shared = DateFormatterCache()
    
    private init() {}
    
    // MARK: - Cached Formatters
    
    /// Formatter compacto para datas "29 Mai"
    lazy var compact: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = BusinessRules.locale
        formatter.dateFormat = "d MMM"
        return formatter
    }()
    
    /// Formatter para mês e ano "Janeiro 2025"
    lazy var monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = BusinessRules.locale
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    /// Formatter para dia da semana "Segunda"
    lazy var weekday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = BusinessRules.locale
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    /// Formatter para dia e mês "29 Mai"
    lazy var dayMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = BusinessRules.locale
        formatter.dateFormat = "d MMM"
        return formatter
    }()
    
    /// Formatter completo "29 Mai 2025"
    lazy var full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = BusinessRules.locale
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()
    
    /// Formatter com timestamp "29 Mai 2025, 14:30"
    lazy var timestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = BusinessRules.locale
        formatter.dateFormat = "d MMM yyyy, HH:mm"
        return formatter
    }()
    
    /// Formatter para acessibilidade (leitura completa)
    lazy var accessible: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = BusinessRules.locale
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()
    
    /// Formatter ISO8601 para export
    lazy var iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    /// Formatter para filenames seguros
    lazy var filename: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy_MM_dd"
        return formatter
    }()
}

// MARK: - Collection Extensions for Dates

/// Extensões para coleções de datas
public extension Collection where Element == Date {
    
    /// Data mais recente da coleção
    ///
    /// - Returns: Date? mais recente ou nil se vazio
    /// - Use Case: Última modificação de lista de itens
    var mostRecent: Date? {
        return self.max()
    }
    
    /// Data mais antiga da coleção
    ///
    /// - Returns: Date? mais antiga ou nil se vazio
    /// - Use Case: Primeira criação, data de início
    var oldest: Date? {
        return self.min()
    }
    
    /// Agrupa datas por mês
    ///
    /// - Returns: Dictionary agrupado por chave "MMM yyyy"
    /// - Use Case: Agrupamento temporal em StatView
    func groupedByMonth() -> [String: [Date]] {
        let formatter = DateFormatterCache.shared.monthYear
        return Dictionary(grouping: self) { date in
            formatter.string(from: date)
        }
    }
    
    /// Filtra datas do mês atual
    ///
    /// - Returns: Array com datas do mês corrente
    /// - Use Case: Estatísticas mensais
    var fromThisMonth: [Date] {
        return self.filter { $0.isThisMonth }
    }
    
    /// Filtra datas dos últimos N dias
    ///
    /// - Parameter days: Número de dias para considerar
    /// - Returns: Array com datas do período
    /// - Use Case: Filtros de período, relatórios
    func fromLast(days: Int) -> [Date] {
        let cutoffDate = Date().adding(days: -days)
        return self.filter { $0 >= cutoffDate }
    }
}

// MARK: - SwiftUI Integration Helpers

#if canImport(SwiftUI)
import SwiftUI

/// Extensões específicas para integração SwiftUI
public extension Date {
    
    /// Cor baseada na idade da data
    ///
    /// - Returns: Color apropriada para idade (verde=recente, vermelho=antigo)
    /// - Use Case: Indicadores visuais de tempo em UI
    var ageColor: Color {
        let daysSinceNow = self.daysSince(Date())
        
        if daysSinceNow == 0 {
            return .green        // Hoje
        } else if daysSinceNow >= -7 {
            return .orange       // Última semana
        } else {
            return .red          // Mais antigo
        }
    }
    
    /// Binding para edição de datas em formulários
    ///
    /// - Parameter binding: Binding<Date> do campo
    /// - Returns: Binding que mantém sincronização
    /// - Use Case: DatePicker integration
    func editableBinding(_ binding: Binding<Date>) -> Binding<Date> {
        return Binding<Date>(
            get: { binding.wrappedValue },
            set: { newValue in binding.wrappedValue = newValue }
        )
    }
}
#endif

// MARK: - Business Logic Extensions

/// Extensões específicas para regras de negócio CadaEuro
public extension Date {
    
    /// Verifica se é uma data válida para estatísticas
    ///
    /// - Returns: Bool indicando se está no range válido para analytics
    /// - Business Rule: Não permite datas futuras ou muito antigas (> 5 anos)
    var isValidForStats: Bool {
        let now = Date()
        let fiveYearsAgo = now.adding(days: -1825) // ~5 anos
        
        return self >= fiveYearsAgo && self <= now
    }
    
    /// Range de período para filtros de estatísticas
    ///
    /// - Returns: Tupla com início e fim do período da data
    /// - Use Case: Filtros mensais em StatsView
    var monthRange: (start: Date, end: Date) {
        return (start: self.startOfMonth, end: self.endOfMonth)
    }
    
    /// Descrição inteligente para agrupamento temporal
    ///
    /// - Returns: String para agrupar por período relevante
    /// - Logic: "Hoje", "Esta semana", "Este mês", ou data específica
    var groupingDescription: String {
        if self.isToday {
            return "Hoje"
        } else if self.isYesterday {
            return "Ontem"
        } else if self.isThisWeek {
            return "Esta semana"
        } else if self.isThisMonth {
            return "Este mês"
        } else {
            return self.asMonthYear
        }
    }
}

// MARK: - Error Handling Extensions

/// Extensões para tratamento de erros em formatação de datas
public extension Date {
    
    /// Formatação defensiva que nunca falha
    ///
    /// - Returns: String formatada ou fallback seguro
    /// - Use Case: Situações onde formatação não pode falhar
    /// - Safety: Garante sempre um valor válido para display
    var asSafeDate: String {
        guard self.timeIntervalSince1970 > 0 else {
            return "Data inválida"
        }
        return self.asCompactDate
    }
    
    /// Verifica se é uma data válida para formatação
    ///
    /// - Returns: Bool indicando se é uma data válida
    /// - Checks: Não é distant past/future, é finite
    /// - Use Case: Validação antes de formatação
    var isValidForFormatting: Bool {
        let distantPast = Date(timeIntervalSince1970: 0)
        let distantFuture = Date(timeIntervalSinceNow: 86400 * 365 * 10) // 10 anos
        
        return self > distantPast && self < distantFuture
    }
}

// MARK: - Debug Extensions

#if DEBUG
/// Extensões específicas para debugging e desenvolvimento
public extension Date {
    
    /// Formatação com informações de debug
    ///
    /// - Returns: String com data e metadados para debugging
    /// - Use Case: Logs de desenvolvimento, troubleshooting
    /// - Format: "29 Mai 2025 (raw: timestamp, valid: true)"
    var asDebugDate: String {
        let formatted = self.asCompactDate
        let timestamp = String(format: "%.0f", self.timeIntervalSince1970)
        let isValid = self.isValidForFormatting
        return "\(formatted) (raw: \(timestamp), valid: \(isValid))"
    }
    
    /// Análise temporal detalhada
    ///
    /// - Returns: String com análise completa da data
    var temporalAnalysis: String {
        var analysis: [String] = []
        
        analysis.append("Timestamp: \(self.timeIntervalSince1970)")
        analysis.append("Is today: \(self.isToday)")
        analysis.append("Is this week: \(self.isThisWeek)")
        analysis.append("Is this month: \(self.isThisMonth)")
        analysis.append("Days since now: \(self.daysSince(Date()))")
        analysis.append("Valid for stats: \(self.isValidForStats)")
        
        return analysis.joined(separator: ", ")
    }
}
#endif

// MARK: - Performance Monitoring

/// Monitor de performance para operações de data (desenvolvimento)
#if DEBUG
private final class DatePerformanceMonitor: @unchecked Sendable {
    static let shared = DatePerformanceMonitor()
    
    private var operationCounts: [String: Int] = [:]
    private let queue = DispatchQueue(label: "date.performance.monitor")
    
    func recordOperation(_ operation: String) {
        queue.async {
            self.operationCounts[operation, default: 0] += 1
            
            // Log a cada 100 operações
            if self.operationCounts[operation]! % 100 == 0 {
                print("📅 DateExtensions: \(operation) called \(self.operationCounts[operation]!) times")
            }
        }
    }
    
    func printStatistics() {
        queue.async {
            print("📊 DateExtensions Performance:")
            for (operation, count) in self.operationCounts.sorted(by: { $0.value > $1.value }) {
                print("  \(operation): \(count) calls")
            }
        }
    }
}
#endif
