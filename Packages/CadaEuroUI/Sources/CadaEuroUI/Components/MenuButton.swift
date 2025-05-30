import SwiftUI
import CadaEuroKit

/// Componente de botão para menu de opções
public struct MenuButton<Content: View>: View {
    @Environment(\.themeProvider) private var themeProvider
    
    /// Conteúdo do menu contextual
    private let menuContent: () -> Content
    
    /// Estado de pressionamento do botão
    @State private var isPressed: Bool = false
    
    /// Estado de rotação do ícone
    @State private var rotationDegrees: Double = 0
    
    /// Inicializador do componente
    /// - Parameter menuContent: Conteúdo do menu contextual
    public init(@ViewBuilder menuContent: @escaping () -> Content) {
        self.menuContent = menuContent
    }
    
    public var body: some View {
        Menu {
            menuContent()
        } label: {
            Image(systemName: "ellipsis")
                .font(themeProvider.theme.typography.bodyLarge)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(themeProvider.theme.colors.cadaEuroComponentBackground.opacity(isPressed ? 0.8 : 0))
                )
                .contentShape(Circle())
                .rotationEffect(.degrees(rotationDegrees))
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(themeProvider.theme.animation.standard) {
                        isPressed = true
                    }
                    
                    // Fornece feedback háptico
                    HapticManager.shared.feedback(.light)
                    
                    // Anima a rotação do ícone
                    withAnimation(themeProvider.theme.animation.standard) {
                        rotationDegrees = 90
                    }
                }
                .onEnded { _ in
                    withAnimation(themeProvider.theme.animation.standard) {
                        isPressed = false
                    }
                }
        )
        .onAppear {
            // Reseta a rotação quando o componente aparece
            rotationDegrees = 0
        }
        .accessibilityLabel("Menu de opções")
        .accessibilityHint("Toque para abrir o menu com opções adicionais")
        .accessibilityAddTraits(.isButton)
    }
}

/// Opção para o menu contextual
public struct MenuOption: View {
    @Environment(\.themeProvider) private var themeProvider
    
    /// Ícone da opção
    private let icon: String
    
    /// Título da opção
    private let title: String
    
    /// Indica se a opção é destrutiva
    private let destructive: Bool
    
    /// Ação a ser executada quando a opção for selecionada
    private let action: () -> Void
    
    /// Inicializador do componente
    /// - Parameters:
    ///   - icon: Ícone SF Symbols
    ///   - title: Título da opção
    ///   - destructive: Indica se a opção é destrutiva
    ///   - action: Ação a ser executada quando a opção for selecionada
    public init(
        icon: String,
        title: String,
        destructive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.destructive = destructive
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            // Fornece feedback háptico
            if destructive {
                HapticManager.shared.feedback(.heavy)
            } else {
                HapticManager.shared.feedback(.medium)
            }
            
            // Executa a ação
            action()
        }) {
            Label {
                Text(title)
                    .foregroundColor(destructive ? themeProvider.theme.colors.cadaEuroError : themeProvider.theme.colors.cadaEuroTextPrimary)
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(destructive ? themeProvider.theme.colors.cadaEuroError : themeProvider.theme.colors.cadaEuroAccent)
            }
        }
        .accessibilityLabel(title)
        .accessibilityHint(destructive ? "Ação destrutiva" : "")
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var showAlert = false
        @State private var alertMessage = ""
        
        var body: some View {
            ZStack {
                themeProvider.theme.colors.cadaEuroBackground
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: themeProvider.theme.spacing.xl) {
                    Text("CadaEuro")
                        .font(themeProvider.theme.typography.titleLarge)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                    
                    HStack {
                        Spacer()
                        
                        MenuButton {
                            MenuOption(
                                icon: "archivebox",
                                title: "Listas guardadas",
                                action: {
                                    alertMessage = "Listas guardadas selecionado"
                                    showAlert = true
                                }
                            )
                            
                            MenuOption(
                                icon: "chart.bar",
                                title: "Estatísticas",
                                action: {
                                    alertMessage = "Estatísticas selecionado"
                                    showAlert = true
                                }
                            )
                            
                            Divider()
                            
                            MenuOption(
                                icon: "gear",
                                title: "Definições",
                                action: {
                                    alertMessage = "Definições selecionado"
                                    showAlert = true
                                }
                            )
                            
                            MenuOption(
                                icon: "trash",
                                title: "Apagar lista",
                                destructive: true,
                                action: {
                                    alertMessage = "Apagar lista selecionado"
                                    showAlert = true
                                }
                            )
                        }
                        .padding(.trailing, themeProvider.theme.spacing.lg)
                    }
                    
                    Spacer()
                    
                    Text("Toque no botão de menu no canto superior direito")
                        .font(themeProvider.theme.typography.bodyMedium)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, themeProvider.theme.spacing.lg)
                    
                    Spacer()
                }
                .alert(alertMessage, isPresented: $showAlert) {
                    Button("OK") {}
                }
            }
            .withThemeProvider(ThemeProvider())
        }
        
        private var themeProvider: ThemeProvider {
            ThemeProvider()
        }
    }
    
    return PreviewWrapper()
}
