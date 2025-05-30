import SwiftUI
import CadaEuroKit

/// Tipos de itens de configuração suportados
public enum SettingsRowType {
    /// Item com toggle (ativar/desativar)
    case toggle(isOn: Binding<Bool>)
    
    /// Item com disclosure indicator (seta para detalhe)
    case disclosure
    
    /// Item com texto de valor à direita
    case value(String)
    
    /// Item com picker
    case picker
    
    /// Item com botão de ação
    case action
}

/// Componente para exibir um item de configuração
public struct SettingsRow: View {
    @Environment(\.themeProvider) private var themeProvider
    
    /// Ícone do item
    private let icon: String
    
    /// Título do item
    private let title: String
    
    /// Descrição do item (opcional)
    private let description: String?
    
    /// Tipo do item
    private let type: SettingsRowType
    
    /// Ação a ser executada ao tocar no item
    private let action: () -> Void
    
    /// Estado de pressionamento para feedback visual
    @State private var isPressed: Bool = false
    
    /// Inicializador do componente
    /// - Parameters:
    ///   - icon: Nome do ícone SF Symbols
    ///   - title: Título do item
    ///   - description: Descrição opcional do item
    ///   - type: Tipo do item de configuração
    ///   - action: Ação a ser executada ao tocar no item
    public init(
        icon: String,
        title: String,
        description: String? = nil,
        type: SettingsRowType,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.type = type
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            HapticManager.shared.feedback(.light)
            action()
        }) {
            HStack(spacing: themeProvider.theme.spacing.sm) {
                // Ícone
                iconView
                
                // Conteúdo de texto
                textContent
                
                Spacer()
                
                // Controlo à direita (toggle, disclosure, etc.)
                trailingContent
            }
            .padding(.vertical, themeProvider.theme.spacing.sm)
            .padding(.horizontal, themeProvider.theme.spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: themeProvider.theme.border.smallButtonRadius)
                    .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
                    .opacity(isPressed ? 0.8 : 1.0)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? themeProvider.theme.animation.pressedScale : 1.0)
        .animation(themeProvider.theme.animation.standard, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation {
                        isPressed = false
                    }
                }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }
    
    /// Ícone do item
    private var iconView: some View {
        Image(systemName: icon)
            .font(themeProvider.theme.typography.bodyMedium)
            .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
            .frame(width: 24, height: 24)
            .accessibilityHidden(true)
    }
    
    /// Conteúdo de texto (título e descrição)
    private var textContent: some View {
        VStack(alignment: .leading, spacing: themeProvider.theme.spacing.xs / 2) {
            Text(title)
                .font(themeProvider.theme.typography.bodyMedium)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                .lineLimit(1)
            
            if let description = description {
                Text(description)
                    .font(themeProvider.theme.typography.captionSmall)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                    .lineLimit(2)
            }
        }
        .accessibilityHidden(true)
    }
    
    /// Conteúdo à direita do item
    @ViewBuilder
    private var trailingContent: some View {
        switch type {
        case .toggle(let isOn):
            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: themeProvider.theme.colors.cadaEuroAccent))
                .onChange(of: isOn.wrappedValue) { newValue in
                    HapticManager.shared.feedback(newValue ? .success : .light)
                }
        
        case .disclosure:
            Image(systemName: "chevron.right")
                .font(themeProvider.theme.typography.caption)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextTertiary)
                .accessibilityHidden(true)
        
        case .value(let value):
            Text(value)
                .font(themeProvider.theme.typography.bodyMedium)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                .accessibilityHidden(true)
        
        case .picker:
            Image(systemName: "chevron.up.chevron.down")
                .font(themeProvider.theme.typography.caption)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextTertiary)
                .accessibilityHidden(true)
        
        case .action:
            Text("Abrir")
                .font(themeProvider.theme.typography.bodySmall)
                .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
                .accessibilityHidden(true)
        }
    }
    
    /// Label de acessibilidade para o item
    private var accessibilityLabel: String {
        switch type {
        case .toggle(let isOn):
            return "\(title), \(isOn.wrappedValue ? "ativado" : "desativado")"
        case .value(let value):
            return "\(title), \(value)"
        default:
            return title
        }
    }
    
    /// Hint de acessibilidade para o item
    private var accessibilityHint: String {
        switch type {
        case .toggle:
            return "Toque duplo para alternar"
        case .disclosure, .picker, .action:
            return "Toque duplo para abrir"
        default:
            return description ?? ""
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var notificationsEnabled = true
        @State private var highContrast = false
        @State private var reduceMotion = false
        
        var body: some View {
            ScrollView {
                VStack(spacing: themeProvider.theme.spacing.sm) {
                    Group {
                        Text("Definições")
                            .font(themeProvider.theme.typography.titleLarge)
                            .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, themeProvider.theme.spacing.lg)
                            .padding(.bottom, themeProvider.theme.spacing.sm)
                        
                        Text("Conta")
                            .font(themeProvider.theme.typography.bodyLarge)
                            .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, themeProvider.theme.spacing.lg)
                            .padding(.top, themeProvider.theme.spacing.sm)
                    }
                    
                    SettingsRow(
                        icon: "person.crop.circle",
                        title: "Gerir plano PRO",
                        description: "Acesso a funcionalidades premium",
                        type: .disclosure,
                        action: {}
                    )
                    
                    SettingsRow(
                        icon: "arrow.clockwise.circle",
                        title: "Restaurar compras",
                        type: .action,
                        action: {}
                    )
                    
                    Text("Personalização")
                        .font(themeProvider.theme.typography.bodyLarge)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, themeProvider.theme.spacing.lg)
                        .padding(.top, themeProvider.theme.spacing.lg)
                    
                    SettingsRow(
                        icon: "textformat.size",
                        title: "Tamanho do texto",
                        type: .value("Médio"),
                        action: {}
                    )
                    
                    SettingsRow(
                        icon: "eurosign.circle",
                        title: "Moeda",
                        type: .picker,
                        action: {}
                    )
                    
                    Text("Sistema")
                        .font(themeProvider.theme.typography.bodyLarge)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, themeProvider.theme.spacing.lg)
                        .padding(.top, themeProvider.theme.spacing.lg)
                    
                    SettingsRow(
                        icon: "bell",
                        title: "Notificações",
                        description: "Receber alertas sobre atualizações",
                        type: .toggle(isOn: $notificationsEnabled),
                        action: {}
                    )
                    
                    Text("Acessibilidade")
                        .font(themeProvider.theme.typography.bodyLarge)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, themeProvider.theme.spacing.lg)
                        .padding(.top, themeProvider.theme.spacing.lg)
                    
                    SettingsRow(
                        icon: "eye",
                        title: "Alto contraste",
                        description: "Melhoria de legibilidade",
                        type: .toggle(isOn: $highContrast),
                        action: {}
                    )
                    
                    SettingsRow(
                        icon: "hand.raised",
                        title: "Redução de movimento",
                        description: "Animações simplificadas",
                        type: .toggle(isOn: $reduceMotion),
                        action: {}
                    )
                }
                .padding(.vertical, themeProvider.theme.spacing.lg)
            }
            .background(themeProvider.theme.colors.cadaEuroBackground)
            .withThemeProvider(ThemeProvider())
        }
        
        private var themeProvider: ThemeProvider {
            ThemeProvider()
        }
    }
    
    return PreviewWrapper()
}
