import SwiftUI
import CadaEuroKit

/// Ações disponíveis no menu principal
public enum MenuAction: CaseIterable, Sendable {
    case savedLists
    case statistics
    case settings
    
    public var title: String {
        switch self {
        case .savedLists: return "Listas guardadas"
        case .statistics: return "Estatísticas"
        case .settings: return "Definições"
        }
    }
    
    public var systemImage: String {
        switch self {
        case .savedLists: return "archivebox"
        case .statistics: return "chart.bar.xaxis"
        case .settings: return "gear"
        }
    }
    
    public var accessibilityHint: String {
        switch self {
        case .savedLists: return "Aceder às suas listas guardadas"
        case .statistics: return "Ver estatísticas e relatórios de gastos"
        case .settings: return "Configurar preferências da aplicação"
        }
    }
}

/// Botão de menu premium com ellipsis para navegação principal
public struct MenuButton: View {
    @Environment(\.themeProvider) private var themeProvider
    
    private let onMenuAction: (MenuAction) -> Void
    
    @State private var isPressed = false
    
    public init(onMenuAction: @escaping (MenuAction) -> Void) {
        self.onMenuAction = onMenuAction
    }
    
    public var body: some View {
        Menu {
            menuContent
        } label: {
            menuLabel
        }
        .menuStyle(.borderlessButton)
        .accessibilityLabel("Menu de opções")
        .accessibilityHint("Abre menu com listas guardadas, estatísticas e definições")
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var menuLabel: some View {
        Image(systemName: "ellipsis")
            .font(.title3)
            .fontWeight(.medium)
            .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
            .frame(width: 44, height: 44) // Touch target mínimo
            .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private var menuContent: some View {
        ForEach(MenuAction.allCases, id: \.self) { action in
            Button(action: {
                onMenuAction(action)
            }) {
                Label(action.title, systemImage: action.systemImage)
            }
            .accessibilityHint(action.accessibilityHint)
        }
    }
}

// MARK: - Custom Button Style

/// Estilo customizado para o botão do menu com microinterações
private struct MenuButtonStyle: ButtonStyle {
    let themeProvider: ThemeProvider
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(themeProvider.theme.animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Previews

#Preview("Menu Button") {
    VStack(spacing: 32) {
        HStack {
            Spacer()
            Text("CadaEuro")
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            MenuButton { action in
                print("Menu action: \(action.title)")
            }
        }
        .padding(.horizontal)
        
        Spacer()
        
        Text("Toque no menu (três pontos) no canto superior direito")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding()
    }
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("Menu Button Dark") {
    HStack {
        Spacer()
        
        VStack(spacing: 16) {
            Text("Menu Button")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            MenuButton { action in
                print("Selected: \(action.title)")
            }
        }
        
        Spacer()
    }
    .padding()
    .background(ThemeProvider.darkPreview.theme.colors.cadaEuroBackground)
    .themeProvider(.darkPreview)
    .preferredColorScheme(.dark)
}

#Preview("Menu Button in Navigation") {
    NavigationStack {
        VStack {
            Text("ShoppingListView")
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            Text("O menu aparece na navigation bar")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
        .navigationTitle("CadaEuro")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                MenuButton { action in
                    switch action {
                    case .savedLists:
                        print("Navigate to Saved Lists")
                    case .statistics:
                        print("Navigate to Statistics")
                    case .settings:
                        print("Navigate to Settings")
                    }
                }
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                MenuButton { action in
                    switch action {
                    case .savedLists:
                        print("Navigate to Saved Lists")
                    case .statistics:
                        print("Navigate to Statistics")
                    case .settings:
                        print("Navigate to Settings")
                    }
                }
            }
            #endif
        }
    }
    .themeProvider(.preview)
}
