import SwiftUI
import Observation

/// Provider principal que gerencia o tema da aplicação CadaEuro
/// Responsável por fornecer acesso centralizado a todos os tokens de design
@Observable
@MainActor
public final class ThemeProvider: Sendable {
    // MARK: - Properties
    /// Esquema de cores atual do sistema
    private var currentColorScheme: ColorScheme = .light
    
    /// Tema atual baseado no esquema de cores
    public private(set) var theme: AppTheme
    
    // MARK: - Initializer
    /// Inicializa o provider com o esquema de cores atual
    public init(colorScheme: ColorScheme = .light) {
        self.currentColorScheme = colorScheme
        self.theme = AppTheme(colorScheme: colorScheme)
    }
    
    // MARK: - Public Methods
    /// Atualiza o tema quando o esquema de cores muda
    /// - Parameter colorScheme: Novo esquema de cores do sistema
    public func updateColorScheme(_ colorScheme: ColorScheme) {
        guard currentColorScheme != colorScheme else { return }
        
        currentColorScheme = colorScheme
        theme = AppTheme(colorScheme: colorScheme)
    }
    
    /// Fornece uma instância de preview para desenvolvimento
    public static let preview = ThemeProvider(colorScheme: .light)
    
    /// Fornece uma instância de preview dark para desenvolvimento
    public static let darkPreview = ThemeProvider(colorScheme: .dark)
}

// MARK: - Environment Key
/// Chave para injeção do ThemeProvider via Environment
private struct ThemeProviderKey: EnvironmentKey {
    static let defaultValue: ThemeProvider? = nil
}

// MARK: - Environment Extension
public extension EnvironmentValues {
    /// Acesso ao ThemeProvider via Environment
    var themeProvider: ThemeProvider {
        @MainActor
        get { 
            guard let provider = self[ThemeProviderKey.self] else {
                // Cria uma nova instância quando não há provider no ambiente
                return ThemeProvider()
            }
            return provider
        }
        set { 
            self[ThemeProviderKey.self] = newValue 
        }
    }
}

// MARK: - View Extensions
public extension View {
    /// Configura o ThemeProvider no ambiente da view
    /// - Parameter provider: Instância do ThemeProvider
    /// - Returns: View configurada com o provider
    /// 
    /// **Uso:** Apenas em views raiz ou quando precisas de uma instância específica
    /// ```swift
    /// ContentView()
    ///     .themeProvider(customProvider)
    /// ```
    func themeProvider(_ provider: ThemeProvider) -> some View {
        self.environment(\.themeProvider, provider)
    }
    
    /// Aplica o tema CadaEuro automaticamente baseado no esquema de cores
    /// - Returns: View com tema aplicado
    /// 
    /// **Uso:** Na view raiz da aplicação (App.swift ou ContentView)
    /// ```swift
    /// NavigationStack {
    ///     ShoppingListView()
    /// }
    /// .cadaEuroTheme()
    /// ```
    func cadaEuroTheme() -> some View {
        self.modifier(CadaEuroThemeModifier())
    }
}

// MARK: - Theme Modifier
/// ViewModifier que aplica automaticamente o tema baseado no esquema de cores
private struct CadaEuroThemeModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @State private var themeProvider = ThemeProvider()
    
    func body(content: Content) -> some View {
        content
            .environment(\.themeProvider, themeProvider)
            .onChange(of: colorScheme) { _, newColorScheme in
                themeProvider.updateColorScheme(newColorScheme)
            }
            .onAppear {
                themeProvider.updateColorScheme(colorScheme)
            }
    }
}
