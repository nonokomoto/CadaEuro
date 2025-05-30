import SwiftUI

/// Provedor de tema para a aplicação CadaEuro
/// Responsável por fornecer o tema atual para todas as views
@Observable @MainActor public class ThemeProvider {
    /// Tema atual da aplicação
    public private(set) var theme: AppTheme
    
    /// Esquema de cores atual
    @ObservedObject private var colorSchemeObserver = ColorSchemeObserver()
    
    /// Inicializador padrão
    public init() {
        self.theme = AppTheme(colorScheme: .light)
        
        // Observar mudanças no esquema de cores
        Task { @MainActor in
            for await colorScheme in colorSchemeObserver.$colorScheme.values {
                updateTheme(to: colorScheme)
            }
        }
    }
    
    /// Atualiza o tema com base no esquema de cores
    private func updateTheme(to colorScheme: ColorScheme) {
        self.theme = AppTheme(colorScheme: colorScheme)
    }
}

/// Extensão para facilitar a aplicação do ThemeProvider em views
public extension View {
    /// Aplica o ThemeProvider a uma hierarquia de views
    func withThemeProvider(_ themeProvider: ThemeProvider) -> some View {
        self.environment(\.themeProvider, themeProvider)
    }
}

/// Chave de ambiente para o ThemeProvider
private struct ThemeProviderKey: EnvironmentKey {
    @MainActor static var defaultValue = ThemeProvider()
}

/// Extensão para adicionar o ThemeProvider ao Environment
public extension EnvironmentValues {
    var themeProvider: ThemeProvider {
        get { self[ThemeProviderKey.self] }
        set { self[ThemeProviderKey.self] = newValue }
    }
}

/// Observer para detectar mudanças no esquema de cores do sistema
@MainActor private class ColorSchemeObserver: ObservableObject {
    @Published var colorScheme: ColorScheme = .light
    
    init() {
        // Em uma implementação real, usaríamos o Environment para obter o esquema de cores
        // Para simplificar, vamos usar um valor padrão por enquanto
        // Em uma aplicação completa, isto seria conectado ao @Environment(\.colorScheme)
        self.colorScheme = .light
    }
    
    // Método para atualizar manualmente o esquema de cores
    // Em uma aplicação real, isto seria feito automaticamente pelo SwiftUI
    func updateColorScheme(to newColorScheme: ColorScheme) {
        self.colorScheme = newColorScheme
    }
}
