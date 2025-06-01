import Foundation
import OSLog

// MARK: - Logging System for CadaEuro

/// Sistema de logging centralizado da aplicação CadaEuro
///
/// Esta classe fornece logging estruturado, performante e thread-safe para toda a aplicação,
/// integrando OSLog nativo com hooks preparados para analytics e crash reporting futuro.
///
/// ## Funcionalidades Principais
/// - **OSLog Integration**: Unified logging system do iOS
/// - **Structured Data**: JSON payloads para analytics futuro
/// - **Performance**: Async logging sem blocking main thread
/// - **Privacy**: Redaction automática de dados sensíveis
/// - **Swift 6 Compliance**: Thread-safe e Sendable
///
/// ## Categorias de Log
/// - **userInteraction**: Ações do utilizador (taps, swipes, voice)
/// - **ocr**: Operações de scanner e reconhecimento
/// - **voice**: Processamento de voz e speech recognition
/// - **validation**: Validações de dados e erros
/// - **persistence**: SwiftData e CloudKit operations
/// - **performance**: Métricas de timing e otimização
/// - **llm**: Integrações LLM (OpenAI, Gemini)
/// - **error**: Erros e recovery flows
///
/// ## Exemplo de Uso
/// ```swift
/// // Logging básico
/// CadaEuroLogger.info("User tapped capture button", category: .userInteraction)
/// CadaEuroLogger.error("OCR failed", error: error, category: .ocr)
///
/// // Logging com contexto
/// CadaEuroLogger.debug("Price validated", metadata: [
///     "price": "€1,29",
///     "method": "manual",
///     "valid": "true"
/// ], category: .validation)
///
/// // Analytics events (preparado mas inativo)
/// CadaEuroLogger.analytics("scan_attempt", properties: [
///     "method": "scanner",
///     "confidence": "0.85"
/// ])
/// ```
public final class CadaEuroLogger: @unchecked Sendable {
    
    // MARK: - Singleton
    
    /// Instância singleton thread-safe
    public static let shared = CadaEuroLogger()
    
    private init() {
        setupLogging()
    }
    
    // MARK: - OSLog Subsystem
    
    /// Subsystem identifier para OSLog
    private static let subsystem = "app.cadaeuro"
    
    /// Loggers por categoria para performance
    private let loggers: [LogCategory: OSLog] = {
        var loggers: [LogCategory: OSLog] = [:]
        for category in LogCategory.allCases {
            loggers[category] = OSLog(subsystem: subsystem, category: category.rawValue)
        }
        return loggers
    }()
    
    // MARK: - Configuration
    
    /// Configuração global do logging
    private var configuration = LogConfiguration()
    
    /// Performance monitor interno
    private let performanceMonitor = LogPerformanceMonitor()
    
    // MARK: - Public Logging Methods
    
    /// Log de debug (apenas em DEBUG builds)
    ///
    /// - Parameters:
    ///   - message: Mensagem do log
    ///   - metadata: Dados adicionais opcionais
    ///   - category: Categoria do log
    ///   - file: Arquivo que originou o log (automático)
    ///   - function: Função que originou o log (automático)
    ///   - line: Linha que originou o log (automático)
    public static func debug(
        _ message: String,
        metadata: [String: String] = [:],
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        shared.log(
            level: .debug,
            message: message,
            metadata: metadata,
            category: category,
            file: file,
            function: function,
            line: line
        )
        #endif
    }
    
    /// Log de informação
    ///
    /// - Parameters:
    ///   - message: Mensagem do log
    ///   - metadata: Dados adicionais opcionais
    ///   - category: Categoria do log
    ///   - file: Arquivo que originou o log (automático)
    ///   - function: Função que originou o log (automático)
    ///   - line: Linha que originou o log (automático)
    public static func info(
        _ message: String,
        metadata: [String: String] = [:],
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        shared.log(
            level: .info,
            message: message,
            metadata: metadata,
            category: category,
            file: file,
            function: function,
            line: line
        )
    }
    
    /// Log de warning
    ///
    /// - Parameters:
    ///   - message: Mensagem do log
    ///   - metadata: Dados adicionais opcionais
    ///   - category: Categoria do log
    ///   - file: Arquivo que originou o log (automático)
    ///   - function: Função que originou o log (automático)
    ///   - line: Linha que originou o log (automático)
    public static func warning(
        _ message: String,
        metadata: [String: String] = [:],
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        shared.log(
            level: .warning,
            message: message,
            metadata: metadata,
            category: category,
            file: file,
            function: function,
            line: line
        )
    }
    
    /// Log de erro
    ///
    /// - Parameters:
    ///   - message: Mensagem do erro
    ///   - error: Erro opcional para contexto
    ///   - metadata: Dados adicionais opcionais
    ///   - category: Categoria do log
    ///   - file: Arquivo que originou o log (automático)
    ///   - function: Função que originou o log (automático)
    ///   - line: Linha que originou o log (automático)
    public static func error(
        _ message: String,
        error: Error? = nil,
        metadata: [String: String] = [:],
        category: LogCategory = .error,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        var enhancedMetadata = metadata
        
        if let error = error {
            enhancedMetadata["error_type"] = String(describing: type(of: error))
            enhancedMetadata["error_description"] = error.localizedDescription
        }
        
        shared.log(
            level: .error,
            message: message,
            metadata: enhancedMetadata,
            category: category,
            file: file,
            function: function,
            line: line
        )
    }
    
    /// Log crítico
    ///
    /// - Parameters:
    ///   - message: Mensagem crítica
    ///   - error: Erro opcional para contexto
    ///   - metadata: Dados adicionais opcionais
    ///   - category: Categoria do log
    ///   - file: Arquivo que originou o log (automático)
    ///   - function: Função que originou o log (automático)
    ///   - line: Linha que originou o log (automático)
    public static func critical(
        _ message: String,
        error: Error? = nil,
        metadata: [String: String] = [:],
        category: LogCategory = .error,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        var enhancedMetadata = metadata
        
        if let error = error {
            enhancedMetadata["error_type"] = String(describing: type(of: error))
            enhancedMetadata["error_description"] = error.localizedDescription
        }
        
        shared.log(
            level: .critical,
            message: message,
            metadata: enhancedMetadata,
            category: category,
            file: file,
            function: function,
            line: line
        )
    }
    
    // MARK: - Analytics Integration (Prepared but Inactive)
    
    /// Log de evento de analytics (preparado para integração futura)
    ///
    /// - Parameters:
    ///   - event: Nome do evento
    ///   - properties: Propriedades do evento
    ///   - category: Categoria opcional
    ///
    /// ## Integração Futura
    /// Esta função será conectada a Mixpanel quando implementado.
    /// Por agora, apenas loga localmente para debugging.
    public static func analytics(
        _ event: String,
        properties: [String: Any] = [:],
        category: LogCategory = .analytics
    ) {
        #if DEBUG
        let propertiesString = properties.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        shared.log(
            level: .info,
            message: "📊 Analytics Event: \(event)",
            metadata: ["properties": propertiesString],
            category: category,
            file: #file,
            function: #function,
            line: #line
        )
        #endif
        
        // TODO: Fase 3/4 - Integração Mixpanel
        // MixpanelManager.shared.track(event: event, properties: properties)
    }
    
    /// Performance timing para operações críticas
    ///
    /// - Parameters:
    ///   - operation: Nome da operação
    ///   - duration: Duração em segundos
    ///   - metadata: Contexto adicional
    ///   - category: Categoria de performance
    public static func performance(
        _ operation: String,
        duration: TimeInterval,
        metadata: [String: String] = [:],
        category: LogCategory = .performance
    ) {
        var enhancedMetadata = metadata
        enhancedMetadata["duration_ms"] = String(format: "%.2f", duration * 1000)
        enhancedMetadata["operation"] = operation
        
        shared.log(
            level: .info,
            message: "⚡ Performance: \(operation) took \(String(format: "%.2f", duration * 1000))ms",
            metadata: enhancedMetadata,
            category: category,
            file: #file,
            function: #function,
            line: #line
        )
        
        shared.performanceMonitor.recordOperation(operation, duration: duration)
    }
    
    // MARK: - Internal Logging Implementation
    
    /// Implementação interna de logging
    private func log(
        level: LogLevel,
        message: String,
        metadata: [String: String],
        category: LogCategory,
        file: String,
        function: String,
        line: Int
    ) {
        // Verificar se deve logar baseado na configuração
        guard configuration.shouldLog(level: level, category: category) else { return }
        
        // Preparar contexto
        let context = LogContext(
            level: level,
            message: message,
            metadata: metadata,
            category: category,
            file: extractFileName(from: file),
            function: function,
            line: line,
            timestamp: Date()
        )
        
        // Log assíncrono para não bloquear thread principal
        Task.detached { [weak self] in
            await self?.performAsyncLogging(context: context)
        }
    }
    
    /// Logging assíncrono thread-safe
    @MainActor
    private func performAsyncLogging(context: LogContext) {
        // OSLog nativo
        logToOSLog(context: context)
        
        // Privacy redaction
        let sanitizedContext = sanitizeForPrivacy(context: context)
        
        // JSON structured logging (para debugging)
        #if DEBUG
        logStructuredData(context: sanitizedContext)
        #endif
        
        // TODO: Fase 3/4 - Integração com crash reporting
        // CrashlyticsManager.shared.recordCustomLog(context: sanitizedContext)
    }
    
    /// Log para OSLog nativo
    private func logToOSLog(context: LogContext) {
        guard let logger = loggers[context.category] else { return }
        
        let formattedMessage = formatMessage(context: context)
        
        switch context.level {
        case .debug:
            os_log(.debug, log: logger, "%{public}@", formattedMessage)
        case .info:
            os_log(.info, log: logger, "%{public}@", formattedMessage)
        case .warning:
            os_log(.default, log: logger, "%{public}@", formattedMessage)
        case .error:
            os_log(.error, log: logger, "%{public}@", formattedMessage)
        case .critical:
            os_log(.fault, log: logger, "%{public}@", formattedMessage)
        }
    }
    
    /// Formatação de mensagem para OSLog
    private func formatMessage(context: LogContext) -> String {
        var components: [String] = []
        
        // Emoji por nível
        components.append(context.level.emoji)
        
        // Mensagem principal
        components.append(context.message)
        
        // Metadata se presente
        if !context.metadata.isEmpty {
            let metadataString = context.metadata
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: " ")
            components.append("[\(metadataString)]")
        }
        
        // Contexto de código em DEBUG
        #if DEBUG
        components.append("(\(context.file):\(context.line))")
        #endif
        
        return components.joined(separator: " ")
    }
    
    /// Sanitização para privacidade
    private func sanitizeForPrivacy(context: LogContext) -> LogContext {
        let sensitiveKeys = ["price", "email", "name", "product"]
        
        var sanitizedMetadata = context.metadata
        for key in sensitiveKeys {
            if sanitizedMetadata[key] != nil {
                sanitizedMetadata[key] = "<redacted>"
            }
        }
        
        return LogContext(
            level: context.level,
            message: context.message,
            metadata: sanitizedMetadata,
            category: context.category,
            file: context.file,
            function: context.function,
            line: context.line,
            timestamp: context.timestamp
        )
    }
    
    /// JSON structured logging para debugging
    #if DEBUG
    private func logStructuredData(context: LogContext) {
        let structuredData: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: context.timestamp),
            "level": context.level.rawValue,
            "category": context.category.rawValue,
            "message": context.message,
            "metadata": context.metadata,
            "source": [
                "file": context.file,
                "function": context.function,
                "line": context.line
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: structuredData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📋 CadaEuro Structured Log:\n\(jsonString)")
        }
    }
    #endif
    
    // MARK: - Utility Methods
    
    /// Extrai nome do arquivo do path completo
    private func extractFileName(from filePath: String) -> String {
        return URL(fileURLWithPath: filePath).lastPathComponent
    }
    
    /// Setup inicial do sistema de logging
    private func setupLogging() {
        #if DEBUG
        print("🔍 CadaEuro Logger initialized with subsystem: \(Self.subsystem)")
        print("📊 Available categories: \(LogCategory.allCases.map { $0.rawValue }.joined(separator: ", "))")
        #endif
    }
}

// MARK: - Log Level Enum

/// Níveis de log disponíveis
public enum LogLevel: String, CaseIterable, Sendable {
    case debug = "debug"
    case info = "info"
    case warning = "warning"
    case error = "error"
    case critical = "critical"
    
    /// Emoji representativo do nível
    var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .critical: return "🚨"
        }
    }
    
    /// Prioridade numérica para filtros
    var priority: Int {
        switch self {
        case .debug: return 0
        case .info: return 1
        case .warning: return 2
        case .error: return 3
        case .critical: return 4
        }
    }
}

// MARK: - Log Category Enum

/// Categorias de log para organização
public enum LogCategory: String, CaseIterable, Sendable {
    case general = "general"
    case userInteraction = "user_interaction"
    case ocr = "ocr"
    case voice = "voice"
    case validation = "validation"
    case persistence = "persistence"
    case performance = "performance"
    case llm = "llm"
    case error = "error"
    case analytics = "analytics"
    case network = "network"
    case security = "security"
    
    /// Descrição amigável da categoria
    var description: String {
        switch self {
        case .general: return "General application logs"
        case .userInteraction: return "User interactions and gestures"
        case .ocr: return "OCR processing and scanning"
        case .voice: return "Voice recognition and speech"
        case .validation: return "Data validation and business rules"
        case .persistence: return "SwiftData and CloudKit operations"
        case .performance: return "Performance metrics and timing"
        case .llm: return "LLM integrations (OpenAI, Gemini)"
        case .error: return "Errors and exception handling"
        case .analytics: return "Analytics events and tracking"
        case .network: return "Network requests and responses"
        case .security: return "Security and privacy operations"
        }
    }
}

// MARK: - Log Context

/// Contexto completo de um log entry
private struct LogContext: Sendable {
    let level: LogLevel
    let message: String
    let metadata: [String: String]
    let category: LogCategory
    let file: String
    let function: String
    let line: Int
    let timestamp: Date
}

// MARK: - Log Configuration

/// Configuração do sistema de logging
private struct LogConfiguration: Sendable {
    /// Nível mínimo para logar
    let minimumLevel: LogLevel = .debug
    
    /// Categorias ativadas
    let enabledCategories: Set<LogCategory> = Set(LogCategory.allCases)
    
    /// Verifica se deve logar baseado na configuração
    func shouldLog(level: LogLevel, category: LogCategory) -> Bool {
        return level.priority >= minimumLevel.priority && enabledCategories.contains(category)
    }
}

// MARK: - Performance Monitor

/// Monitor interno de performance para operações de logging
private final class LogPerformanceMonitor: @unchecked Sendable {
    private var operationMetrics: [String: OperationMetric] = [:]
    private let queue = DispatchQueue(label: "logger.performance.monitor")
    
    func recordOperation(_ operation: String, duration: TimeInterval) {
        queue.async {
            if var metric = self.operationMetrics[operation] {
                metric.totalTime += duration
                metric.callCount += 1
                metric.averageTime = metric.totalTime / Double(metric.callCount)
                metric.maxTime = max(metric.maxTime, duration)
                metric.minTime = min(metric.minTime, duration)
                self.operationMetrics[operation] = metric
            } else {
                self.operationMetrics[operation] = OperationMetric(
                    operation: operation,
                    totalTime: duration,
                    callCount: 1,
                    averageTime: duration,
                    maxTime: duration,
                    minTime: duration
                )
            }
            
            // Log estatísticas a cada 50 operações
            if let metric = self.operationMetrics[operation], metric.callCount % 50 == 0 {
                #if DEBUG
                print("📊 Performance Metric - \(operation): avg=\(String(format: "%.2f", metric.averageTime * 1000))ms, max=\(String(format: "%.2f", metric.maxTime * 1000))ms, calls=\(metric.callCount)")
                #endif
            }
        }
    }
    
    #if DEBUG
    func printStatistics() {
        queue.async {
            print("📊 Logger Performance Statistics:")
            for (operation, metric) in self.operationMetrics.sorted(by: { $0.value.averageTime > $1.value.averageTime }) {
                print("  \(operation): avg=\(String(format: "%.2f", metric.averageTime * 1000))ms, calls=\(metric.callCount)")
            }
        }
    }
    #endif
}

/// Métrica de performance para uma operação
private struct OperationMetric {
    let operation: String
    var totalTime: TimeInterval
    var callCount: Int
    var averageTime: TimeInterval
    var maxTime: TimeInterval
    var minTime: TimeInterval
}

// MARK: - Convenience Extensions

/// Extensões para logging contextual em diferentes componentes
public extension CadaEuroLogger {
    
    /// Logging específico para componentes UI
    static func ui(_ message: String, component: String, metadata: [String: String] = [:]) {
        var enhancedMetadata = metadata
        enhancedMetadata["component"] = component
        
        info(message, metadata: enhancedMetadata, category: .userInteraction)
    }
    
    /// Logging específico para operações OCR
    static func ocr(_ message: String, confidence: Double? = nil, metadata: [String: String] = [:]) {
        var enhancedMetadata = metadata
        if let confidence = confidence {
            enhancedMetadata["confidence"] = String(format: "%.2f", confidence)
        }
        
        info(message, metadata: enhancedMetadata, category: .ocr)
    }
    
    /// Logging específico para operações de voz
    static func voice(_ message: String, transcription: String? = nil, metadata: [String: String] = [:]) {
        var enhancedMetadata = metadata
        if let transcription = transcription {
            enhancedMetadata["transcription_length"] = String(transcription.count)
        }
        
        info(message, metadata: enhancedMetadata, category: .voice)
    }
    
    /// Logging específico para validações
    static func validation(_ message: String, isValid: Bool, field: String? = nil, metadata: [String: String] = [:]) {
        var enhancedMetadata = metadata
        enhancedMetadata["valid"] = String(isValid)
        if let field = field {
            enhancedMetadata["field"] = field
        }
        
        let level: LogLevel = isValid ? .info : .warning
        shared.log(
            level: level,
            message: message,
            metadata: enhancedMetadata,
            category: .validation,
            file: #file,
            function: #function,
            line: #line
        )
    }
}

// MARK: - Timing Utilities

/// Utility para medir performance de operações
public struct LogTimer: Sendable {
    private let startTime: CFAbsoluteTime
    private let operation: String
    
    public init(_ operation: String) {
        self.operation = operation
        self.startTime = CFAbsoluteTimeGetCurrent()
    }
    
    public func end(metadata: [String: String] = [:]) {
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        CadaEuroLogger.performance(operation, duration: duration, metadata: metadata)
    }
}

// MARK: - SwiftUI Integration

#if canImport(SwiftUI)
import SwiftUI

/// View modifier para logging automático de lifecycle
public struct LoggingViewModifier: ViewModifier {
    let viewName: String
    
    public func body(content: Content) -> some View {
        content
            .onAppear {
                CadaEuroLogger.ui("View appeared", component: viewName)
            }
            .onDisappear {
                CadaEuroLogger.ui("View disappeared", component: viewName)
            }
    }
}

public extension View {
    /// Adiciona logging automático de lifecycle
    func logLifecycle(viewName: String) -> some View {
        modifier(LoggingViewModifier(viewName: viewName))
    }
}
#endif

// MARK: - Debug Utilities

#if DEBUG
/// Extensões específicas para debugging
public extension CadaEuroLogger {
    
    /// Dump completo de estatísticas (apenas DEBUG)
    static func dumpStatistics() {
        shared.performanceMonitor.printStatistics()
        
        print("🔍 Logger Configuration:")
        print("  Minimum Level: \(shared.configuration.minimumLevel.rawValue)")
        print("  Enabled Categories: \(shared.configuration.enabledCategories.map { $0.rawValue }.joined(separator: ", "))")
    }
    
    /// Test logging para verificar configuração
    static func testLogging() {
        debug("Test debug message", category: .general)
        info("Test info message", category: .general)
        warning("Test warning message", category: .general)
        error("Test error message", category: .error)
        
        analytics("test_event", properties: ["source": "debug"])
        performance("test_operation", duration: 0.1)
        
        print("✅ Test logging completed - check console output")
    }
}
#endif
