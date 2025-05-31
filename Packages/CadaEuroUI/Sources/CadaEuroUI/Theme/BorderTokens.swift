import SwiftUI

/// Tokens de bordas e cantos da aplicação CadaEuro
public struct BorderTokens {
    // MARK: - Corner Radius
    /// Raio pequeno para botões e elementos menores (8px)
    public let radiusSmall: CGFloat
    
    /// Raio médio para cards e componentes (12px)
    public let radiusMedium: CGFloat
    
    /// Raio grande para containers principais (16px)
    public let radiusLarge: CGFloat
    
    /// Raio extra grande para elementos destacados (20px)
    public let radiusXLarge: CGFloat
    
    // MARK: - Border Width
    /// Largura fina para bordas sutis (1px)
    public let widthThin: CGFloat
    
    /// Largura média para bordas visíveis (2px)
    public let widthMedium: CGFloat
    
    /// Largura grossa para bordas de destaque (3px)
    public let widthThick: CGFloat
    
    // MARK: - Aliases para componentes específicos
    /// Raio para botões padrão (12px)
    public var buttonRadius: CGFloat { radiusMedium }
    
    /// Raio para cards (16px)
    public var cardRadius: CGFloat { radiusLarge }
    
    /// Raio para inputs de formulário (8px)
    public var inputRadius: CGFloat { radiusSmall }
    
    /// Raio para menus e modais (20px)
    public var menuRadius: CGFloat { radiusXLarge }
    
    /// Largura para bordas de foco (2px)
    public var focusBorderWidth: CGFloat { widthMedium }
    
    /// Largura para separadores (1px)
    public var separatorWidth: CGFloat { widthThin }
    
    // MARK: - Initializer
    /// Inicializa os tokens de bordas com os valores padrão
    public init() {
        // Utilizamos múltiplos de 4px para manter consistência
        self.radiusSmall = 8
        self.radiusMedium = 12
        self.radiusLarge = 16
        self.radiusXLarge = 20
        
        self.widthThin = 1
        self.widthMedium = 2
        self.widthThick = 3
    }
}
