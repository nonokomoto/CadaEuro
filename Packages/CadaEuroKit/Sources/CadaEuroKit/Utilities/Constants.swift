import Foundation
import SwiftUI

// MARK: - App Configuration

/// Configuração básica da aplicação CadaEuro
///
/// Esta enum centraliza todas as informações fundamentais sobre a aplicação,
/// incluindo versionamento, targets e identificadores únicos.
///
/// ## Uso
/// ```swift
/// let appName = AppConstants.name // "CadaEuro"
/// let version = AppConstants.version // "1.0.0"
/// ```
public enum AppConstants {
    /// Nome oficial da aplicação
    ///
    /// - Returns: String com o nome "CadaEuro"
    public static let name = "CadaEuro"
    
    /// Versão atual da aplicação seguindo Semantic Versioning
    ///
    /// - Returns: String no formato "MAJOR.MINOR.PATCH"
    /// - Note: Deve ser sincronizada com Info.plist CFBundleShortVersionString
    public static let version = "1.0.0"
    
    /// Bundle identifier único para App Store e sistema iOS
    ///
    /// - Returns: String com identificador único
    /// - Important: Deve corresponder exatamente ao PRODUCT_BUNDLE_IDENTIFIER do Xcode
    public static let bundleIdentifier = "NeyCarvalho.CadaEuro"
    
    /// Versão mínima do iOS suportada pela aplicação
    ///
    /// - Returns: String "18.4" representando iOS 18.4+ conforme IPHONEOS_DEPLOYMENT_TARGET
    public static let minimumIOSVersion = "18.4"
    
    /// Target de build especificando plataforma e versão
    ///
    /// - Returns: String descritiva do target
    /// - Note: Usado para documentação e debugging
    public static let buildTarget = "iOS 18.4+"
}

// MARK: - Business Rules

/// Regras de negócio fundamentais da aplicação CadaEuro
///
/// Esta enum centraliza todas as validações, limites e configurações que
/// definem o comportamento comercial da aplicação. Valores baseados em
/// pesquisa de mercado e experiência de utilizador.
///
/// ## Exemplo de Uso
/// ```swift
/// // Validação de preço
/// if price < BusinessRules.minPrice || price > BusinessRules.maxPrice {
///     throw ValidationError.priceOutOfRange
/// }
///
/// // Validação de nome
/// if productName.count > BusinessRules.maxProductNameLength {
///     throw ValidationError.nameTooLong
/// }
/// ```
public enum BusinessRules {
    // MARK: - Limites de Preços
    
    /// Preço mínimo permitido por produto (€0.01)
    ///
    /// - Returns: Double representando 1 cêntimo
    /// - Note: Baseado na menor denominação monetária do Euro
    /// - Important: Usado em ManualInputForm e validações OCR
    public static let minPrice: Double = 0.01
    
    /// Preço máximo permitido por produto (€999.999,99)
    ///
    /// - Returns: Double representando limite superior prático
    /// - Note: Baseado em produtos de supermercado de luxo
    /// - Warning: Valores acima deste limite são rejeitados
    public static let maxPrice: Double = 999999.99
    
    // MARK: - Limites de Quantidades
    
    /// Quantidade mínima permitida por item
    ///
    /// - Returns: Int 1 (não é possível ter 0 itens)
    /// - Note: Lógica comercial não permite quantidades negativas ou zero
    public static let minQuantity: Int = 1
    
    /// Quantidade máxima permitida por item (10.000 unidades)
    ///
    /// - Returns: Int representando limite prático para supermercado
    /// - Note: Baseado em compras empresariais ou eventos especiais
    /// - Performance: Evita problemas de UI com números enormes
    public static let maxQuantity: Int = 10000
    
    // MARK: - Validação de Texto
    
    /// Comprimento máximo permitido para nome de produto (100 caracteres)
    ///
    /// - Returns: Int representando limite de caracteres
    /// - Note: Baseado em etiquetas de supermercado mais longas
    /// - UI: Garante boa experiência em ItemCard e listas
    /// - Accessibility: Compatível com VoiceOver sem truncamento
    public static let maxProductNameLength: Int = 100
    
    /// Comprimento mínimo para nome de produto (1 caracter)
    ///
    /// - Returns: Int representando mínimo obrigatório
    /// - Note: Previne produtos com nomes vazios
    /// - Validation: Aplicado após trim de whitespace
    public static let minProductNameLength: Int = 1
    
    /// Comprimento máximo para nome de lista de compras (50 caracteres)
    ///
    /// - Returns: Int adequado para UI de SavedListsView
    /// - Note: Balança entre expressividade e layout
    /// - UX: Nomes concisos facilitam navegação
    public static let maxListNameLength: Int = 50
    
    /// Comprimento mínimo para nome de lista (1 caracter)
    ///
    /// - Returns: Int evitando listas sem nome
    /// - Default: "Lista de compras" usado quando vazio
    public static let minListNameLength: Int = 1
    
    // MARK: - Formatação Monetária
    
    /// Código ISO 4217 da moeda padrão da aplicação
    ///
    /// - Returns: String "EUR" para Euro
    /// - Note: Usado em formatadores NumberFormatter
    /// - Localization: Preparado para futuras moedas regionais
    public static let defaultCurrency = "EUR"
    
    /// Símbolo visual da moeda para exibição na UI
    ///
    /// - Returns: String "€" para representação visual
    /// - UI: Usado em campos de preço e displays de total
    /// - Accessibility: Lido corretamente pelo VoiceOver
    public static let currencySymbol = "€"
    
    /// Locale português para formatação de números e datas
    ///
    /// - Returns: Locale configurado para Portugal (pt_PT)
    /// - Format: Vírgula como separador decimal (€1,99)
    /// - Date: Formato dia/mês/ano
    /// - Numbers: Espaço como separador de milhares
    public static let locale = Locale(identifier: "pt_PT")
}

// MARK: - Performance Constants

/// Constantes de performance baseadas no documento técnico
///
/// Estes valores definem os SLAs (Service Level Agreements) da aplicação
/// e são derivados de benchmarks da indústria e experiência do utilizador.
/// Todos os timeouts são projetados para balance entre funcionalidade e UX.
///
/// ## Performance Targets
/// - **Cold Start**: < 1s para primeira tela
/// - **OCR Recognition**: < 300ms por item
/// - **Voice Processing**: < 10s total
/// - **LLM Response**: < 5s para normalização
///
/// ## Exemplo de Uso
/// ```swift
/// // OCR timeout
/// let ocrTask = Task {
///     await withTimeout(PerformanceConstants.ocrTimeoutSeconds) {
///         return try await processOCR(image)
///     }
/// }
/// ```
public enum PerformanceConstants {
    // MARK: - OCR Performance
    
    /// Timeout máximo para reconhecimento OCR por item (300ms)
    ///
    /// - Returns: TimeInterval baseado em documento técnico
    /// - Target: < 300ms conforme especificação
    /// - Method: On-device VisionKit TextRecognizer
    /// - Fallback: Manual input se exceder timeout
    /// - Performance: Crítico para UX fluida do scanner
    public static let ocrTimeoutSeconds: TimeInterval = 0.3
    
    /// Timeout para processamento de imagem antes do OCR (2s)
    ///
    /// - Returns: TimeInterval para pré-processamento
    /// - Includes: Binarização, rotação, crop via CIImage
    /// - Note: Separado do OCR para debugging granular
    /// - Fallback: Imagem original se timeout
    public static let imageProcessingTimeoutSeconds: TimeInterval = 2.0
    
    // MARK: - Voice Processing
    
    /// Timeout total para reconhecimento de voz (10s)
    ///
    /// - Returns: TimeInterval máximo para transcrição completa
    /// - Method: SFSpeechRecognizer on-device
    /// - UX: Inclui tempo para user pensar e falar
    /// - Accessibility: Considera utilizadores com dificuldades
    public static let voiceTimeoutSeconds: TimeInterval = 10.0
    
    /// Duração mínima de gravação aceita (500ms)
    ///
    /// - Returns: TimeInterval evitando gravações acidentais
    /// - UX: Previne clicks involuntários do botão
    /// - Quality: Tempo mínimo para fala reconhecível
    /// - Error: VoiceRecorderError.recordingTooShort se menor
    public static let minimumRecordingDuration: TimeInterval = 0.5
    
    /// Duração máxima de gravação permitida (30s)
    ///
    /// - Returns: TimeInterval para evitar gravações infinitas
    /// - Memory: Limita uso de memória e storage
    /// - UX: Force cut-off com processamento automático
    /// - Battery: Previne drain excessivo do microfone
    public static let maximumRecordingDuration: TimeInterval = 30.0
    
    // MARK: - LLM Processing
    
    /// Timeout para processamento via LLM (5s)
    ///
    /// - Returns: TimeInterval para GPT-4.1 mini / Gemini 2 Flash
    /// - Network: Inclui latência de rede + processamento
    /// - Fallback: Gemini se OpenAI timeout, manual se ambos falharem
    /// - Cost: Balance entre qualidade e custo por request
    public static let llmTimeoutSeconds: TimeInterval = 5.0
    
    /// Duração do cache para respostas LLM (5 minutos)
    ///
    /// - Returns: Int minutos para NSCache
    /// - Memory: Cache inteligente para produtos repetidos
    /// - Cost: Reduz calls desnecessárias ao LLM
    /// - Freshness: Balance entre performance e dados atuais
    public static let llmCacheDurationMinutes: Int = 5
    
    // MARK: - Animation Durations
    
    /// Duração de animação rápida para feedback imediato (150ms)
    ///
    /// - Returns: TimeInterval para button press, hover states
    /// - Psychology: Perceived instant response
    /// - Examples: CaptureButton scale, ItemCard press
    /// - Battery: Minimal impact em animações frequentes
    public static let quickAnimationDuration: TimeInterval = 0.15
    
    /// Duração de animação padrão para transições (300ms)
    ///
    /// - Returns: TimeInterval para modal presentations, navigation
    /// - Standard: Alinhado com Human Interface Guidelines
    /// - Examples: Sheet modal, NavigationStack transitions
    /// - Perception: Natural flow sem ser sluggish
    public static let standardAnimationDuration: TimeInterval = 0.3
    
    /// Duração de animação lenta para emphasis (500ms)
    ///
    /// - Returns: TimeInterval para success states, important changes
    /// - Psychology: Draw attention para ações importantes
    /// - Examples: Total update, list save confirmation
    /// - Accessibility: Tempo para processar mudanças visuais
    public static let slowAnimationDuration: TimeInterval = 0.5
    
    // MARK: - App Performance
    
    /// Tempo máximo de arranque cold permitido (1s)
    ///
    /// - Returns: TimeInterval conforme documento técnico
    /// - Target: < 1s para primeira tela utilizável
    /// - Measurement: App launch até ShoppingListView completa
    /// - Optimization: SwiftData preload, minimal setup
    public static let coldStartTimeoutSeconds: TimeInterval = 1.0
    
    /// Target de crash-free sessions (99%)
    ///
    /// - Returns: Double representing 0.99 (99%)
    /// - Monitoring: Firebase Crashlytics tracking
    /// - Alert: Slack notification se abaixo do target
    /// - Quality: Stability KPI para App Store rating
    public static let crashFreeSessionsTarget: Double = 0.99
}

// MARK: - API Configuration

/// Configuração de APIs e networking para integração com serviços externos
///
/// Centraliza URLs, timeouts, retry logic e configurações de cache
/// para todas as chamadas de rede da aplicação.
///
/// ## Serviços Integrados
/// - **OpenAI GPT-4.1 mini**: Processamento principal LLM
/// - **Google Gemini 2 Flash**: Fallback para OpenAI
/// - **Retry Logic**: Exponential backoff com circuit breaker
/// - **Caching**: Intelligent caching para reduzir custos
///
/// ## Exemplo de Uso
/// ```swift
/// let client = OpenAIClient(
///     baseURL: APIConstants.openAIBaseURL,
///     timeout: APIConstants.networkTimeoutSeconds
/// )
/// 
/// let response = try await client.completions(
///     prompt: ocrText,
///     maxRetries: APIConstants.maxRetryAttempts
/// )
/// ```
public enum APIConstants {
    // MARK: - LLM Endpoints
    
    /// Base URL para OpenAI API v1
    ///
    /// - Returns: String com endpoint oficial OpenAI
    /// - Service: GPT-4.1 mini para normalização de texto OCR/Voice
    /// - Authentication: Requires API key via Keychain
    /// - Rate Limits: Managed automaticamente pelo SDK
    public static let openAIBaseURL = "https://api.openai.com/v1"
    
    /// Base URL para Google Gemini API v1
    ///
    /// - Returns: String com endpoint oficial Google AI
    /// - Service: Gemini 2 Flash como fallback para OpenAI
    /// - Authentication: Google API key via Keychain
    /// - Cost: Significantly cheaper que OpenAI para fallback
    public static let geminiBaseURL = "https://generativelanguage.googleapis.com/v1"
    
    // MARK: - Retry Logic
    
    /// Número máximo de tentativas de retry para requests falhados
    ///
    /// - Returns: Int 3 tentativas (initial + 2 retries)
    /// - Strategy: Exponential backoff com jitter
    /// - Cost: Balance entre reliability e API costs
    /// - Circuit Breaker: Para em caso de falhas sistemáticas
    public static let maxRetryAttempts: Int = 3
    
    /// Delay base entre tentativas de retry (1 segundo)
    ///
    /// - Returns: TimeInterval para primeiro retry
    /// - Strategy: 1s, 2s, 4s com exponential backoff
    /// - Jitter: ±20% para evitar thundering herd
    /// - Network: Permite recuperação de blips temporários
    public static let retryDelaySeconds: TimeInterval = 1.0
    
    /// Multiplicador exponential para delays de retry (2x)
    ///
    /// - Returns: Double para calcular próximo delay
    /// - Formula: delay = baseDelay * (multiplier ^ attemptNumber)
    /// - Example: 1s → 2s → 4s para 3 tentativas
    /// - Backpressure: Reduz carga em services degradados
    public static let retryBackoffMultiplier: Double = 2.0
    
    // MARK: - Network Timeouts
    
    /// Timeout para requests HTTP padrão (30s)
    ///
    /// - Returns: TimeInterval adequado para LLM responses
    /// - LLM: Inclui processing time para prompts complexos
    /// - Mobile: Considera conexões 3G/4G instáveis
    /// - UX: Evita waits infinitos com feedback ao user
    public static let networkTimeoutSeconds: TimeInterval = 30.0
    
    /// Timeout específico para upload de dados (60s)
    ///
    /// - Returns: TimeInterval para uploads maiores
    /// - Future: Preparado para upload de imagens OCR
    /// - Network: Considera uploads em conexões lentas
    /// - Size: Adequado para imagens processadas
    public static let uploadTimeoutSeconds: TimeInterval = 60.0
    
    // MARK: - Cache Settings
    
    /// Duração de cache para respostas LLM (5 minutos)
    ///
    /// - Returns: Int minutos para cache inteligente
    /// - Cost: Reduz calls redundantes ao LLM
    /// - Memory: NSCache com automatic eviction
    /// - Freshness: Balance entre performance e data currency
    /// - Key Strategy: Hash de input text para deduplication
    public static let llmCacheDurationMinutes: Int = 5
    
    /// Tamanho máximo do cache em megabytes (50MB)
    ///
    /// - Returns: Int MB para limite de memória
    /// - Memory: Evita excessive memory usage
    /// - Performance: Sufficient para session típica
    /// - Eviction: LRU policy para cache management
    public static let maxCacheSizeMB = 50
}

// MARK: - UI Constants

/// Constantes de interface que não pertencem ao Theme
public enum UIConstants {
    // MARK: - Haptic Feedback Intensities
    
    /// Intensidade de feedback háptico leve
    public static let lightHapticIntensity: Float = 0.5
    
    /// Intensidade de feedback háptico médio
    public static let mediumHapticIntensity: Float = 0.7
    
    /// Intensidade de feedback háptico forte
    public static let heavyHapticIntensity: Float = 1.0
    
    // MARK: - Touch Targets
    
    /// Tamanho mínimo para touch targets (acessibilidade)
    public static let minimumTouchTarget: CGFloat = 44.0
    
    /// Tamanho de botão padrão
    public static let standardButtonSize: CGFloat = 64.0
    
    /// Tamanho de botão pequeno
    public static let smallButtonSize: CGFloat = 32.0
    
    // MARK: - Accessibility
    
    /// Timeout para ações de acessibilidade
    public static let accessibilityTimeout: TimeInterval = 30.0
    
    /// Contraste mínimo exigido (WCAG 2.1 AA)
    public static let minimumContrastRatio: Double = 4.5
    
    // MARK: - Layout
    
    /// Margem padrão para conteúdo
    public static let defaultContentMargin: CGFloat = 16.0
    
    /// Margem grande para seções
    public static let largeSectionMargin: CGFloat = 32.0
}

// MARK: - Security Constants

/// Configurações de segurança e privacidade
public enum SecurityConstants {
    // MARK: - Keychain Keys
    
    /// Chave para API key do OpenAI no Keychain
    public static let openAIKeychainKey = "cadaeuro.openai.key"
    
    /// Chave para API key do Gemini no Keychain
    public static let geminiKeychainKey = "cadaeuro.gemini.key"
    
    /// Chave para settings do utilizador no Keychain
    public static let userSettingsKeychainKey = "cadaeuro.user.settings"
    
    // MARK: - Data Protection
    
    /// Nível de proteção de ficheiros
    public static let fileProtectionLevel = FileProtectionType.completeUntilFirstUserAuthentication
    
    // MARK: - Privacy
    
    /// Identificador para dados anónimos
    public static let anonymousDataIdentifier = "anonymous_user"
    
    /// Tempo de retenção de dados (em dias)
    public static let dataRetentionDays: Int = 365
}

// MARK: - Analytics Events

/// Eventos de analytics centralizados
public enum AnalyticsEvents {
    // MARK: - Core Events
    
    /// Item adicionado à lista
    public static let itemAdded = "item_added"
    
    /// Lista de compras completada
    public static let listCompleted = "list_completed"
    
    /// Nova lista criada
    public static let listCreated = "list_created"
    
    /// Lista guardada
    public static let listSaved = "list_saved"
    
    // MARK: - Capture Method Events (✅ INTEGRADO com CaptureMethod)
    
    /// Sucesso no reconhecimento OCR - usa CaptureMethod.scanner.analyticsName
    public static let ocrSuccess = CaptureMethod.scanner.analyticsName + "_success"
    
    /// Falha no reconhecimento OCR - usa CaptureMethod.scanner.analyticsName
    public static let ocrFailed = CaptureMethod.scanner.analyticsName + "_failed"
    
    /// Sucesso no reconhecimento de voz - usa CaptureMethod.voice.analyticsName
    public static let voiceSuccess = CaptureMethod.voice.analyticsName + "_success"
    
    /// Falha no reconhecimento de voz - usa CaptureMethod.voice.analyticsName
    public static let voiceFailed = CaptureMethod.voice.analyticsName + "_failed"
    
    /// Entrada manual utilizada - usa CaptureMethod.manual.analyticsName
    public static let manualInput = CaptureMethod.manual.analyticsName
    
    // MARK: - Capture Method Process Events (✅ NOVO: Eventos de processo)
    
    /// Tentativa de scan iniciada
    public static let scanAttempt = CaptureMethod.scanner.analyticsName + "_attempt"
    
    /// Processamento OCR iniciado
    public static let scanProcessingStarted = CaptureMethod.scanner.analyticsName + "_processing_started"
    
    /// Tentativa de gravação de voz iniciada
    public static let voiceRecordingStarted = CaptureMethod.voice.analyticsName + "_recording_started"
    
    /// Transcrição de voz completada
    public static let voiceTranscriptionCompleted = CaptureMethod.voice.analyticsName + "_transcription_completed"
    
    /// Produto adicionado via entrada manual
    public static let manualProductAdded = CaptureMethod.manual.analyticsName + "_product_added"

    // MARK: - Navigation Events
    
    /// Acesso a listas guardadas
    public static let savedListsViewed = "saved_lists_viewed"
    
    /// Acesso a estatísticas
    public static let statisticsViewed = "statistics_viewed"
    
    /// Acesso a definições
    public static let settingsViewed = "settings_viewed"
    
    // MARK: - Error Events
    
    /// Erro de permissão de câmara
    public static let cameraPermissionDenied = "camera_permission_denied"
    
    /// Erro de permissão de microfone
    public static let microphonePermissionDenied = "microphone_permission_denied"
    
    /// Erro de rede
    public static let networkError = "network_error"
    
    /// Crash da aplicação
    public static let appCrashed = "app_crashed"
}

// MARK: - CloudKit Constants

/// Configurações para CloudKit
public enum CloudKitConstants {
    // MARK: - Container
    
    /// Identificador do container CloudKit
    public static let containerIdentifier = "iCloud.com.cadaeuro.app"
    
    // MARK: - Record Types
    
    /// Tipo de record para ShoppingItem
    public static let shoppingItemRecordType = "ShoppingItem"
    
    /// Tipo de record para ShoppingList
    public static let shoppingListRecordType = "ShoppingList"
    
    /// Tipo de record para UserSettings
    public static let userSettingsRecordType = "UserSettings"
    
    // MARK: - Sync Configuration
    
    /// Intervalo de sincronização automática (em segundos)
    public static let autoSyncIntervalSeconds: TimeInterval = 30.0
    
    /// Timeout para operações CloudKit
    public static let cloudKitTimeoutSeconds: TimeInterval = 15.0
    
    /// Número máximo de records por batch
    public static let maxRecordsPerBatch: Int = 100
}

// MARK: - Feature Flags

/// Feature flags para funcionalidades experimentais
public enum FeatureFlags {
    // MARK: - Beta Features
    
    /// Ativar funcionalidades experimentais
    public static let enableExperimentalFeatures: Bool = false
    
    /// Ativar debug logging
    public static let enableDebugLogging: Bool = true
    
    /// Ativar analytics detalhado
    public static let enableDetailedAnalytics: Bool = true
    
    // MARK: - LLM Features
    
    /// Usar Gemini como fallback
    public static let enableGeminiFallback: Bool = true
    
    /// Cache de respostas LLM
    public static let enableLLMCaching: Bool = true
    
    // MARK: - Performance Features
    
    /// Otimizações de performance
    public static let enablePerformanceOptimizations: Bool = true
    
    /// Pré-carregamento de dados
    public static let enableDataPreloading: Bool = false
}
