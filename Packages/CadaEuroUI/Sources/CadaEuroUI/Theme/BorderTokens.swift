import SwiftUI

/// Tokens de bordas e cantos da aplicação CadaEuro
public struct BorderTokens {
    // MARK: - Corner Radius
    /// Raio de canto para cards (16px)
    public let cardRadius: CGFloat
    
    /// Raio de canto para botões pequenos (12px)
    public let smallButtonRadius: CGFloat
    
    /// Raio de canto para botões circulares (metade da largura/altura)
    public let circularButtonRadius: CGFloat
    
    // MARK: - Border Width
    /// Largura de borda padrão (1px)
    public let standardBorderWidth: CGFloat
    
    /// Largura de borda para elementos destacados (2px)
    public let emphasizedBorderWidth: CGFloat
    
    // MARK: - Shadow
    /// Raio de sombra para nível 1 (8px)
    public let shadowRadius1: CGFloat
    
    /// Offset Y de sombra para nível 1 (4px)
    public let shadowYOffset1: CGFloat
    
    /// Raio de sombra para nível 2 (16px)
    public let shadowRadius2: CGFloat
    
    /// Offset Y de sombra para nível 2 (8px)
    public let shadowYOffset2: CGFloat
    
    /// Raio de sombra para efeito glow (12px)
    public let glowRadius: CGFloat
    
    // MARK: - Initializer
    /// Inicializa os tokens de bordas com os valores padrão
    public init() {
        self.cardRadius = 16
        self.smallButtonRadius = 12
        self.circularButtonRadius = .infinity // Para criar círculos perfeitos
        self.standardBorderWidth = 1
        self.emphasizedBorderWidth = 2
        self.shadowRadius1 = 8
        self.shadowYOffset1 = 4
        self.shadowRadius2 = 16
        self.shadowYOffset2 = 8
        self.glowRadius = 12
    }
}
