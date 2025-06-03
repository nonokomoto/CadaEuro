import SwiftUI
import Combine
import CadaEuroKit

/// ViewModel para a tela de definições do CadaEuro
///
/// Esta classe gerencia o estado das configurações da aplicação, fornecendo
/// dados mock temporários até que a implementação completa seja realizada.
/// Segue os padrões estabelecidos de Swift 6 e SwiftUI.
///
/// ## Funcionalidades
/// - **Conta**: Gestão de perfil e subscrição
/// - **Dados**: Backup, sincronização e privacidade
/// - **Personalização**: Tema, idioma e preferências visuais
/// - **Acessibilidade**: VoiceOver, tamanho de texto e contrastes
/// - **Suporte**: FAQ, contacto e informações legais
@MainActor
public final class SettingsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Indica se a view está a carregar dados
    @Published public var isLoading: Bool = false
    
    /// Mensagem de erro, se existir
    @Published public var errorMessage: String?
    
    // MARK: - Account Section Properties
    
    /// Indica se tem subscrição premium ativa (mock)
    @Published public var hasPremiumSubscription: Bool = false
    
    /// Data de expiração da subscrição (mock)
    @Published public var subscriptionExpiryDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    /// Tipo de plano atual (mock)
    @Published public var currentPlan: SubscriptionPlan = .free
    
    // MARK: - Data Section Properties
    
    /// Indica se backup automático está ativo (mock)
    @Published public var isAutoBackupEnabled: Bool = true
    
    /// Indica se sincronização iCloud está ativa (mock)
    @Published public var isiCloudSyncEnabled: Bool = true
    
    /// Quantidade de dados em cache (mock)
    @Published public var cacheSize: String = "12,3 MB"
    
    /// Data da última sincronização (mock)
    @Published public var lastSyncDate: Date = Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date()
    
    // MARK: - Personalization Section Properties
    
    /// Tema selecionado (mock)
    @Published public var selectedTheme: ThemeMode = .system
    
    /// Idioma selecionado (mock)
    @Published public var selectedLanguage: AppLanguage = .portuguese
    
    /// Moeda preferida (mock)
    @Published public var preferredCurrency: Currency = .euro
    
    /// Formato de número preferido (mock)
    @Published public var numberFormat: NumberFormat = .european
    
    // MARK: - Accessibility Section Properties
    
    /// Tamanho de texto personalizado (mock)
    @Published public var textSize: TextSize = .medium
    
    /// Indica se modo alto contraste está ativo (mock)
    @Published public var isHighContrastEnabled: Bool = false
    
    /// Indica se redução de movimento está ativa (mock)
    @Published public var isReduceMotionEnabled: Bool = false
    
    /// Indica se VoiceOver está ativo (mock)
    @Published public var isVoiceOverEnabled: Bool = false
    
    // MARK: - Support Section Properties
    
    /// Versão da aplicação
    @Published public var appVersion: String = AppConstants.version
    
    /// Build number (mock)
    @Published public var buildNumber: String = "2024.1.1"
    
    /// Tamanho total da aplicação (mock)
    @Published public var appSize: String = "45,2 MB"
    
    // MARK: - Initialization
    
    public init() {
        CadaEuroLogger.info("SettingsViewModel initialized", category: .userInteraction)
        // Atualizar plano atual baseado na subscrição
        updateCurrentPlan()
        loadSettings()
    }
    
    // MARK: - Public Methods
    
    /// Atualiza o plano atual baseado na subscrição premium
    private func updateCurrentPlan() {
        currentPlan = hasPremiumSubscription ? .premium : .free
    }
    
    /// Carrega as configurações (mock)
    public func loadSettings() {
        isLoading = true
        errorMessage = nil
        
        Task {
            await MainActor.run {
                // Simula carregamento de dados
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isLoading = false
                    CadaEuroLogger.info("Settings loaded successfully", category: .userInteraction)
                }
            }
        }
    }
    
    /// Actualiza o tema selecionado
    public func updateTheme(_ theme: ThemeMode) {
        selectedTheme = theme
        CadaEuroLogger.info("Theme updated to: \(theme.rawValue)", category: .userInteraction)
    }
    
    /// Actualiza o idioma selecionado
    public func updateLanguage(_ language: AppLanguage) {
        selectedLanguage = language
        CadaEuroLogger.info("Language updated to: \(language.rawValue)", category: .userInteraction)
    }
    
    /// Toggle do backup automático
    public func toggleAutoBackup() {
        isAutoBackupEnabled.toggle()
        CadaEuroLogger.info("Auto backup toggled: \(isAutoBackupEnabled)", category: .userInteraction)
    }
    
    /// Toggle da sincronização iCloud
    public func toggleiCloudSync() {
        isiCloudSyncEnabled.toggle()
        CadaEuroLogger.info("iCloud sync toggled: \(isiCloudSyncEnabled)", category: .userInteraction)
    }
    
    /// Toggle do alto contraste
    public func toggleHighContrast() {
        isHighContrastEnabled.toggle()
        CadaEuroLogger.info("High contrast toggled: \(isHighContrastEnabled)", category: .userInteraction)
    }
    
    /// Toggle da redução de movimento
    public func toggleReduceMotion() {
        isReduceMotionEnabled.toggle()
        CadaEuroLogger.info("Reduce motion toggled: \(isReduceMotionEnabled)", category: .userInteraction)
    }
    
    /// Actualiza o tamanho do texto
    public func updateTextSize(_ size: TextSize) {
        textSize = size
        CadaEuroLogger.info("Text size updated to: \(size.rawValue)", category: .userInteraction)
    }
    
    /// Limpa a cache da aplicação
    public func clearCache() {
        isLoading = true
        
        Task {
            await MainActor.run {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.cacheSize = "0 MB"
                    self.isLoading = false
                    CadaEuroLogger.info("Cache cleared successfully", category: .userInteraction)
                }
            }
        }
    }
    
    /// Inicia processo de upgrade para premium
    public func upgradeToPremium() {
        CadaEuroLogger.info("Premium upgrade initiated", category: .userInteraction)
        // TODO: Implementar lógica de upgrade quando sistema de pagamentos estiver pronto
        
        // Simular upgrade para demonstração
        hasPremiumSubscription = true
        updateCurrentPlan()
    }
    
    /// Abre FAQ
    public func openFAQ() {
        CadaEuroLogger.info("FAQ opened", category: .userInteraction)
        // TODO: Implementar navegação para FAQ
    }
    
    /// Abre contacto
    public func openContact() {
        CadaEuroLogger.info("Contact opened", category: .userInteraction)
        // TODO: Implementar funcionalidade de contacto
    }
    
    /// Força sincronização manual
    public func syncNow() {
        isLoading = true
        
        Task {
            await MainActor.run {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.lastSyncDate = Date()
                    self.isLoading = false
                    CadaEuroLogger.info("Manual sync completed", category: .userInteraction)
                }
            }
        }
    }
}

// MARK: - Supporting Enums

/// Modos de tema disponíveis
public enum ThemeMode: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    public var displayName: String {
        switch self {
        case .light: return "Claro"
        case .dark: return "Escuro"
        case .system: return "Sistema"
        }
    }
}

/// Idiomas suportados pela aplicação
public enum AppLanguage: String, CaseIterable {
    case portuguese = "pt"
    case english = "en"
    
    public var displayName: String {
        switch self {
        case .portuguese: return "Português"
        case .english: return "English"
        }
    }
}

/// Moedas suportadas
public enum Currency: String, CaseIterable {
    case euro = "EUR"
    case dollar = "USD"
    case pound = "GBP"
    
    public var displayName: String {
        switch self {
        case .euro: return "Euro (€)"
        case .dollar: return "Dólar ($)"
        case .pound: return "Libra (£)"
        }
    }
}

/// Formatos de número
public enum NumberFormat: String, CaseIterable {
    case european = "european"
    case american = "american"
    
    public var displayName: String {
        switch self {
        case .european: return "Europeu (1.234,56)"
        case .american: return "Americano (1,234.56)"
        }
    }
}

/// Tamanhos de texto
public enum TextSize: String, CaseIterable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    case extraLarge = "extraLarge"
    
    public var displayName: String {
        switch self {
        case .small: return "Pequeno"
        case .medium: return "Médio"
        case .large: return "Grande"
        case .extraLarge: return "Extra Grande"
        }
    }
    
    public var scaleFactor: CGFloat {
        switch self {
        case .small: return 0.85
        case .medium: return 1.0
        case .large: return 1.15
        case .extraLarge: return 1.3
        }
    }
}

/// Planos de subscrição disponíveis
public enum SubscriptionPlan: String, CaseIterable {
    case free = "free"
    case premium = "premium"
    case family = "family"
    
    public var displayName: String {
        switch self {
        case .free: return "Plano Gratuito"
        case .premium: return "Premium"
        case .family: return "Familiar"
        }
    }
    
    public var description: String {
        switch self {
        case .free: return "Funcionalidades básicas"
        case .premium: return "Funcionalidades avançadas"
        case .family: return "Até 6 membros da família"
        }
    }
}
