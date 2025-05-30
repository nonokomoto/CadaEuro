import SwiftUI

/// Tokens de tipografia da aplicação CadaEuro
public struct TypographyTokens {
    // MARK: - Heading
    /// Fonte para o total principal (48pt, Medium)
    public let totalPrice: Font
    
    /// Fonte para títulos de secção (28pt, Medium/Bold)
    public let titleLarge: Font
    
    /// Fonte para subtítulos (20pt, Medium)
    public let titleMedium: Font
    
    // MARK: - Body
    /// Fonte para texto principal (18pt, Medium/Regular)
    public let bodyLarge: Font
    
    /// Fonte para texto secundário (17pt, Regular)
    public let bodyMedium: Font
    
    /// Fonte para labels pequenos (16pt, Regular)
    public let bodySmall: Font
    
    // MARK: - Caption
    /// Fonte para captions (14pt, Medium)
    public let caption: Font
    
    /// Fonte para labels mínimos (12pt, Medium)
    public let captionSmall: Font
    
    // MARK: - Initializer
    /// Inicializa os tokens de tipografia com os valores padrão
    public init() {
        // Utilizamos a fonte do sistema (SF Pro) para garantir consistência com o iOS
        // e suporte completo ao Dynamic Type
        self.totalPrice = .system(size: 48, weight: .medium, design: .default)
        self.titleLarge = .system(size: 28, weight: .semibold, design: .default)
        self.titleMedium = .system(size: 20, weight: .medium, design: .default)
        self.bodyLarge = .system(size: 18, weight: .medium, design: .default)
        self.bodyMedium = .system(size: 17, weight: .regular, design: .default)
        self.bodySmall = .system(size: 16, weight: .regular, design: .default)
        self.caption = .system(size: 14, weight: .medium, design: .default)
        self.captionSmall = .system(size: 12, weight: .medium, design: .default)
    }
}
