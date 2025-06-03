import SwiftUI

/// Componente reutilizável para linhas de configuração no SettingsView
///
/// Este componente representa uma linha individual de configuração, podendo
/// conter diferentes tipos de controles como toggle, picker, ou simples navegação.
public struct SettingsRow: View {
    @Environment(\.themeProvider) private var themeProvider
    
    private let title: String
    private let subtitle: String?
    private let systemImage: String?
    private let content: SettingsRowContent
    private let action: (() -> Void)?
    
    public init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        content: SettingsRowContent = .navigation,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.content = content
        self.action = action
    }
    
    public var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: themeProvider.theme.spacing.md) {
                // Ícone opcional
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(themeProvider.theme.typography.bodyMedium)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
                        .frame(width: 24, height: 24)
                }
                
                // Conteúdo principal
                VStack(alignment: .leading, spacing: themeProvider.theme.spacing.xs) {
                    Text(title)
                        .font(themeProvider.theme.typography.bodyMedium)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                        .multilineTextAlignment(.leading)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(themeProvider.theme.typography.bodySmall)
                            .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                // Conteúdo da direita baseado no tipo
                contentView
            }
            .padding(.horizontal, themeProvider.theme.spacing.lg)
            .padding(.vertical, themeProvider.theme.spacing.md)
            .background(themeProvider.theme.colors.cadaEuroComponentBackground)
            .cornerRadius(themeProvider.theme.border.cardRadius)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(content.isDisabled || action == nil)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch content {
        case .navigation:
            Image(systemName: "chevron.right")
                .font(themeProvider.theme.typography.bodySmall)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextTertiary)
        
        case .toggle(let binding):
            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(themeProvider.theme.colors.cadaEuroAccent)
        
        case .text(let value):
            Text(value)
                .font(themeProvider.theme.typography.bodySmall)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
        
        case .badge(let value):
            Text(value)
                .font(themeProvider.theme.typography.bodySmall)
                .foregroundColor(themeProvider.theme.colors.cadaEuroWhiteText)
                .padding(.horizontal, themeProvider.theme.spacing.sm)
                .padding(.vertical, themeProvider.theme.spacing.xs)
                .background(themeProvider.theme.colors.cadaEuroAccent)
                .cornerRadius(themeProvider.theme.border.cardRadius / 2)
        
        case .disabled:
            EmptyView()
        }
    }
}

/// Tipos de conteúdo disponíveis para SettingsRow
public enum SettingsRowContent {
    case navigation
    case toggle(Binding<Bool>)
    case text(String)
    case badge(String)
    case disabled
    
    var isDisabled: Bool {
        if case .disabled = self {
            return true
        }
        return false
    }
}

// MARK: - Convenience Initializers

extension SettingsRow {
    /// Inicializador para linha com toggle
    public init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        isOn: Binding<Bool>,
        onToggle: @escaping () -> Void = {}
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            systemImage: systemImage,
            content: .toggle(isOn),
            action: onToggle
        )
    }
    
    /// Inicializador para linha com texto informativo
    public init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        value: String
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            systemImage: systemImage,
            content: .text(value),
            action: nil
        )
    }
    
    /// Inicializador para linha com badge
    public init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        badge: String
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            systemImage: systemImage,
            content: .badge(badge),
            action: nil
        )
    }
    
    /// Inicializador para linha de navegação
    public init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        onTap: @escaping () -> Void
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            systemImage: systemImage,
            content: .navigation,
            action: onTap
        )
    }
}

#Preview("Settings Rows") {
    VStack(spacing: 12) {
        SettingsRow(
            title: "Backup Automático",
            subtitle: "Guarda automaticamente as suas listas",
            systemImage: "icloud.and.arrow.up",
            isOn: .constant(true)
        )
        
        SettingsRow(
            title: "Versão da Aplicação",
            systemImage: "info.circle",
            value: "1.0.0"
        )
        
        SettingsRow(
            title: "Premium",
            subtitle: "Desbloqueie funcionalidades avançadas",
            systemImage: "crown",
            badge: "Novo"
        )
        
        SettingsRow(
            title: "Privacidade",
            subtitle: "Gerir permissões e dados",
            systemImage: "lock.shield",
            onTap: {}
        )
    }
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}
