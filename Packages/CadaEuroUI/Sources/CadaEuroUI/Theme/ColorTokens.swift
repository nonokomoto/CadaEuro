import SwiftUI

/// Tokens de cores da aplicação CadaEuro
public struct ColorTokens {
    // MARK: - Backgrounds
    /// Cor de fundo principal da aplicação
    public let cadaEuroBackground: Color
    
    /// Cor de fundo para componentes como cards
    public let cadaEuroComponentBackground: Color
    
    // MARK: - Text
    /// Cor de texto primário (títulos, texto principal)
    public let cadaEuroTextPrimary: Color
    
    /// Cor de texto secundário (subtítulos, descrições)
    public let cadaEuroTextSecondary: Color
    
    /// Cor de texto terciário (informações menos importantes)
    public let cadaEuroTextTertiary: Color
    
    // MARK: - Accent
    /// Cor de destaque principal (botões, links, total)
    public let cadaEuroAccent: Color
    
    /// Cor de destaque com efeito glow (apenas dark mode)
    public let cadaEuroTotalPrice: Color
    
    // MARK: - Status
    /// Cor para indicar sucesso
    public let cadaEuroSuccess: Color
    
    /// Cor para indicar erro
    public let cadaEuroError: Color
    
    /// Cor para indicar aviso
    public let cadaEuroWarning: Color
    
    // MARK: - Interactive
    /// Cor para elementos interativos em estado disabled
    public let cadaEuroDisabled: Color
    
    /// Cor para bordas e separadores
    public let cadaEuroSeparator: Color
    
    // MARK: - Constantes
    /// Cor branca pura para texto em botões primários
    public let cadaEuroWhiteText: Color
    
    // MARK: - Initializer
    /// Inicializa os tokens de cores com base no esquema de cores atual
    public init(colorScheme: ColorScheme) {
        switch colorScheme {
        case .dark:
            // Dark Mode - Elegante, Acessível e Moderno
            self.cadaEuroBackground = Color(hex: "#0A0A0B") // Preto suave, mais elegante que puro
            self.cadaEuroComponentBackground = Color(hex: "#1A1A1C") // Cinza muito escuro, sofisticado
            self.cadaEuroTextPrimary = Color(hex: "#F5F5F7") // Branco suave, menos agressivo
            self.cadaEuroTextSecondary = Color(hex: "#98989D") // Cinza médio, elegante
            self.cadaEuroTextTertiary = Color(hex: "#6D6D70") // Cinza sutil
            self.cadaEuroAccent = Color(hex: "#0A84FF") // Azul moderno, levemente mais vibrante
            self.cadaEuroTotalPrice = Color(hex: "#0A84FF").opacity(0.3) // Glow sutil
            self.cadaEuroSuccess = Color(hex: "#30D158") // Verde moderno
            self.cadaEuroError = Color(hex: "#FF453A") // Vermelho suave
            self.cadaEuroWarning = Color(hex: "#FF9F0A") // Laranja elegante
            self.cadaEuroDisabled = Color(hex: "#48484A") // Quaternary label
            self.cadaEuroSeparator = Color(hex: "#38383A") // Separador sutil
            self.cadaEuroWhiteText = Color(hex: "#FFFFFF")
            
        default:
            // Light Mode - Minimalista, Elegante e Sofisticado
            self.cadaEuroBackground = Color(hex: "#FAFAFA") // Branco quente, mais suave
            self.cadaEuroComponentBackground = Color(hex: "#F8F9FA") // Cinza muito claro, elegante
            self.cadaEuroTextPrimary = Color(hex: "#1A1A1A") // Preto suave, não puro
            self.cadaEuroTextSecondary = Color(hex: "#6B7280") // Cinza moderno, equilibrado
            self.cadaEuroTextTertiary = Color(hex: "#9CA3AF") // Cinza claro, sutil
            self.cadaEuroAccent = Color(hex: "#0066CC") // Azul refinado, menos vibrante
            self.cadaEuroTotalPrice = Color.clear // Sem glow no modo claro
            self.cadaEuroSuccess = Color(hex: "#059669") // Verde elegante, menos saturado
            self.cadaEuroError = Color(hex: "#DC2626") // Vermelho sofisticado
            self.cadaEuroWarning = Color(hex: "#D97706") // Laranja equilibrado
            self.cadaEuroDisabled = Color(hex: "#D1D5DB") // Cinza suave
            self.cadaEuroSeparator = Color(hex: "#E5E7EB") // Separador muito sutil
            self.cadaEuroWhiteText = Color(hex: "#FFFFFF")
        }
    }
}

// MARK: - Color Extension
extension Color {
    /// Inicializa uma cor a partir de um valor hexadecimal
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
