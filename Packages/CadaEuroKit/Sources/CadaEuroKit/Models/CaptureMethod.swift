import Foundation
import SwiftUI

/// Métodos de captura disponíveis na aplicação CadaEuro
/// Enum centralizado e compartilhado entre todos os packages
public enum CaptureMethod: String, CaseIterable, Sendable {
    /// Captura via scanner OCR de etiquetas de preços
    case scanner = "camera"
    
    /// Captura via reconhecimento de voz
    case voice = "mic"
    
    /// Entrada manual via teclado
    case manual = "keyboard"
    
    // ✅ FUTURO: Métodos de extensão planejados (comentados)
    // case import = "import"     // Importação de listas externas
    // case ai = "ai"             // Sugestões automáticas IA
}

// MARK: - UI Properties (para CadaEuroUI)

public extension CaptureMethod {
    /// Título descritivo do método em português PT
    var title: String {
        switch self {
        case .scanner: return "Capturar com câmara"
        case .voice: return "Gravar com microfone"
        case .manual: return "Adicionar manualmente"
        }
    }
    
    /// Ícone do sistema SF Symbols
    var systemImage: String {
        switch self {
        case .scanner: return "camera.viewfinder"
        case .voice: return "mic.fill"
        case .manual: return "keyboard"
        }
    }
    
    /// Cor de destaque específica do método
    var accentColor: Color {
        switch self {
        case .scanner: return .blue
        case .voice: return .green
        case .manual: return .orange
        }
    }
    
    /// Hint de acessibilidade descritivo
    var accessibilityHint: String {
        switch self {
        case .scanner: return "Abre scanner para ler etiquetas de preços"
        case .voice: return "Inicia gravação de voz para adicionar produto"
        case .manual: return "Abre formulário para entrada manual"
        }
    }
}

// MARK: - Analytics Properties (para tracking)

public extension CaptureMethod {
    /// Nome para analytics e telemetria
    var analyticsName: String {
        switch self {
        case .scanner: return "ocr_label_scan"
        case .voice: return "voice_capture"
        case .manual: return "manual_input"
        }
    }
    
    /// Prioridade para ordenação na UI (menor = mais prioritário)
    var priority: Int {
        switch self {
        case .scanner: return 1  // OCR é o método principal
        case .voice: return 2    // Voz como segundo método
        case .manual: return 3   // Manual como fallback
        }
    }
}

// MARK: - Business Logic Properties

public extension CaptureMethod {
    /// Indica se o método requer permissões específicas
    var requiresPermissions: Bool {
        switch self {
        case .scanner: return true   // Permissão de câmara
        case .voice: return true     // Permissão de microfone
        case .manual: return false   // Não requer permissões
        }
    }
    
    /// Indica se o método processa dados via LLM
    var usesLLMProcessing: Bool {
        switch self {
        case .scanner: return true   // OCR → LLM normalização
        case .voice: return true     // Speech → LLM normalização
        case .manual: return false   // Input direto
        }
    }
    
    /// Tempo estimado de processamento em segundos
    var estimatedProcessingTime: TimeInterval {
        switch self {
        case .scanner: return 2.0    // OCR + LLM processing
        case .voice: return 3.0      // Speech recognition + LLM
        case .manual: return 0.0     // Instantâneo
        }
    }
}

// MARK: - Error Recovery Properties

public extension CaptureMethod {
    /// Método de fallback recomendado em caso de erro
    var fallbackMethod: CaptureMethod {
        switch self {
        case .scanner: return .manual    // OCR falha → entrada manual
        case .voice: return .manual      // Voz falha → entrada manual
        case .manual: return .manual     // Manual não tem fallback
        }
    }
    
    /// Texto do botão de fallback para error recovery
    var fallbackButtonText: String {
        switch self {
        case .scanner: return "Adicionar manualmente"
        case .voice: return "Adicionar manualmente"
        case .manual: return "Tentar novamente"
        }
    }
}

// MARK: - Sorting & Filtering

public extension CaptureMethod {
    /// Métodos ordenados por prioridade (scanner → voice → manual)
    static var byPriority: [CaptureMethod] {
        return allCases.sorted { $0.priority < $1.priority }
    }
    
    /// Métodos que requerem permissões
    static var requirePermissions: [CaptureMethod] {
        return allCases.filter { $0.requiresPermissions }
    }
    
    /// Métodos instantâneos (sem processamento)
    static var instantMethods: [CaptureMethod] {
        return allCases.filter { $0.estimatedProcessingTime == 0 }
    }
}
