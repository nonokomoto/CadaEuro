import SwiftUI

/// Tokens de espaçamento da aplicação CadaEuro
public struct SpacingTokens {
    // MARK: - Tamanhos padrão
    /// Espaçamento extra pequeno (8px)
    public let xs: CGFloat
    
    /// Espaçamento pequeno (16px)
    public let sm: CGFloat
    
    /// Espaçamento médio (20px) - margins globais
    public let lg: CGFloat
    
    /// Espaçamento grande (24px) - padding horizontal cards
    public let xl: CGFloat
    
    /// Espaçamento extra grande (40px) - espaçamento seções
    public let xxl: CGFloat
    
    /// Espaçamento máximo (80px) - espaçamento grande entre seções
    public let xxxl: CGFloat
    
    // MARK: - Aliases para compatibilidade
    /// Margem lateral global (20px)
    public var horizontalMargin: CGFloat { lg }
    
    /// Espaçamento entre secções (40px)
    public var sectionSpacing: CGFloat { xxl }
    
    /// Espaçamento grande entre secções (80px)
    public var largeSectionSpacing: CGFloat { xxxl }
    
    /// Padding horizontal para cards (24px)
    public var cardHorizontalPadding: CGFloat { xl }
    
    /// Padding vertical para cards (20px)
    public var cardVerticalPadding: CGFloat { lg }
    
    /// Padding padrão (16px)
    public var standardPadding: CGFloat { sm }
    
    /// Espaçamento entre botões principais (40px)
    public var buttonSpacing: CGFloat { xxl }
    
    /// Espaçamento entre indicadores de modo (8px)
    public var indicatorSpacing: CGFloat { xs }
    
    /// Espaçamento entre itens em listas (12px)
    public var listItemSpacing: CGFloat { xs + 4 }
    
    /// Margem superior para o header (20px)
    public var headerTopMargin: CGFloat { lg }
    
    /// Margem superior para o total (60px)
    public var totalTopMargin: CGFloat { xxl + lg }
    
    /// Margem superior para os botões (40px)
    public var buttonsTopMargin: CGFloat { xxl }
    
    // MARK: - Initializer
    /// Inicializa os tokens de espaçamento com os valores padrão
    public init() {
        // Utilizamos um grid de 8px como base para os espaçamentos
        self.xs = 8
        self.sm = 16
        self.lg = 20
        self.xl = 24
        self.xxl = 40
        self.xxxl = 80
    }
}
