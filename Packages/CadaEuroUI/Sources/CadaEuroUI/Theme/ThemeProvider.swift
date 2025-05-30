import SwiftUI

/// Provedor de tema para a aplicação CadaEuro
/// Responsável por fornecer o tema atual para todas as views
@Observable public class ThemeProvider {
    /// Tema atual da aplicação
    public private(set) var theme: AppTheme
    
    /// Esquema de cores atual
    @ObservedObject private var colorSchemeObserver = ColorSchemeObserver()
    
    /// Inicializador padrão
    public init() {
        self.theme = AppTheme(colorScheme: .light)
        updateTheme(to: colorSchemeObserver.colorScheme)
        
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
    static let defaultValue = ThemeProvider()
}

/// Extensão para adicionar o ThemeProvider ao Environment
public extension EnvironmentValues {
    var themeProvider: ThemeProvider {
        get { self[ThemeProviderKey.self] }
        set { self[ThemeProviderKey.self] = newValue }
    }
}

/// Observer para detectar mudanças no esquema de cores do sistema
private class ColorSchemeObserver: ObservableObject {
    @Published var colorScheme: ColorScheme = .light
    
    init() {
        // Configurar para detectar mudanças no esquema de cores
        // Inicialmente, usamos o valor padrão .light
        // Em uma implementação real, obteríamos o valor atual do sistema
        updateColorScheme()
        
        // Registrar para notificações de mudança de aparência
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateColorScheme),
            name: UITraitCollection.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func updateColorScheme() {
        DispatchQueue.main.async {
            self.colorScheme = UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
