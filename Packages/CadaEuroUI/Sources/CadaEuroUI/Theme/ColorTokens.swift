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
    
    // MARK: - Initializer
    /// Inicializa os tokens de cores com base no esquema de cores atual
    public init(colorScheme: ColorScheme) {
        switch colorScheme {
        case .dark:
            // Dark Mode
            self.cadaEuroBackground = Color(hex: "#000000") // Preto puro Apple Store
            self.cadaEuroComponentBackground = Color(hex: "#1C1C1E") // Cinza escuro Apple
            self.cadaEuroTextPrimary = Color(hex: "#FFFFFF") // Branco puro
            self.cadaEuroTextSecondary = Color(hex: "#EBEBF5").opacity(0.6) // Branco com 60% opacidade
            self.cadaEuroTextTertiary = Color(hex: "#EBEBF5").opacity(0.3) // Branco com 30% opacidade
            self.cadaEuroAccent = Color(hex: "#007AFF") // Apple System Blue
            self.cadaEuroTotalPrice = Color(hex: "#007AFF").opacity(0.4) // Glow azul com 40% opacidade
            self.cadaEuroSuccess = Color.green
            self.cadaEuroError = Color.red
            self.cadaEuroWarning = Color.orange
            self.cadaEuroDisabled = Color(hex: "#3A3A3C")
            self.cadaEuroSeparator = Color(hex: "#38383A")
            
        default:
            // Light Mode
            self.cadaEuroBackground = Color(hex: "#F8F9FA") // Cinza sofisticado luxury
            self.cadaEuroComponentBackground = Color.white.opacity(0.85) // Branco com 85% de opacidade
            self.cadaEuroTextPrimary = Color(hex: "#1C1C1E") // Preto Apple
            self.cadaEuroTextSecondary = Color(hex: "#3C3C43") // Cinza médio
            self.cadaEuroTextTertiary = Color(hex: "#8E8E93") // Cinza claro
            self.cadaEuroAccent = Color(hex: "#007AFF") // Apple System Blue
            self.cadaEuroTotalPrice = Color.clear // Sem glow no modo claro
            self.cadaEuroSuccess = Color.green
            self.cadaEuroError = Color.red
            self.cadaEuroWarning = Color.orange
            self.cadaEuroDisabled = Color(hex: "#C7C7CC")
            self.cadaEuroSeparator = Color(hex: "#C6C6C8")
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
