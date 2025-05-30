import SwiftUI

/// Estrutura principal que contém todos os tokens de design da aplicação CadaEuro
public struct AppTheme {
    /// Tokens de cores da aplicação
    public let colors: ColorTokens
    
    /// Tokens de tipografia da aplicação
    public let typography: TypographyTokens
    
    /// Tokens de espaçamento da aplicação
    public let spacing: SpacingTokens
    
    /// Tokens de animação da aplicação
    public let animation: AnimationTokens
    
    /// Tokens de bordas e cantos da aplicação
    public let border: BorderTokens
    
    /// Inicializador padrão que configura todos os tokens para o tema atual
    public init(colorScheme: ColorScheme) {
        self.colors = ColorTokens(colorScheme: colorScheme)
        self.typography = TypographyTokens()
        self.spacing = SpacingTokens()
        self.animation = AnimationTokens()
        self.border = BorderTokens()
    }
}

/// Extensão para fornecer um tema padrão para previews
public extension AppTheme {
    static let lightPreview = AppTheme(colorScheme: .light)
    static let darkPreview = AppTheme(colorScheme: .dark)
}
