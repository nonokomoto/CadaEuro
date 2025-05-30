import SwiftUI

/// Tokens de animação da aplicação CadaEuro
public struct AnimationTokens {
    // MARK: - Durations
    /// Duração padrão para animações (300ms)
    public let standardDuration: Double
    
    /// Duração curta para feedback rápido (150ms)
    public let shortDuration: Double
    
    /// Duração longa para transições complexas (500ms)
    public let longDuration: Double
    
    // MARK: - Scales
    /// Escala para botões pressionados (0.98)
    public let pressedScale: CGFloat
    
    /// Escala para menus ativos (0.9)
    public let activeMenuScale: CGFloat
    
    /// Escala para itens adicionados (1.2)
    public let addedItemScale: CGFloat
    
    /// Escala para total atualizado (1.02)
    public let updatedTotalScale: CGFloat
    
    // MARK: - Spring Parameters
    /// Resposta para animações spring (0.3)
    public let springResponse: Double
    
    /// Amortecimento para animações spring (0.7)
    public let springDamping: Double
    
    // MARK: - Initializer
    /// Inicializa os tokens de animação com os valores padrão
    public init() {
        self.standardDuration = 0.3
        self.shortDuration = 0.15
        self.longDuration = 0.5
        self.pressedScale = 0.98
        self.activeMenuScale = 0.9
        self.addedItemScale = 1.2
        self.updatedTotalScale = 1.02
        self.springResponse = 0.3
        self.springDamping = 0.7
    }
    
    // MARK: - Animation Presets
    /// Animação padrão para transições
    public var standard: Animation {
        .easeInOut(duration: standardDuration)
    }
    
    /// Animação rápida para feedback
    public var quick: Animation {
        .easeInOut(duration: shortDuration)
    }
    
    /// Animação spring para elementos interativos
    public var spring: Animation {
        .spring(response: springResponse, dampingFraction: springDamping)
    }
}
