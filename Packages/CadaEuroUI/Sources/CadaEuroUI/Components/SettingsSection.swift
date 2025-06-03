import SwiftUI

/// Componente para seções organizadas no SettingsView
///
/// Este componente agrupa linhas de configuração relacionadas em seções
/// visualmente distintas com título e descrição opcional.
public struct SettingsSection<Content: View>: View {
    @Environment(\.themeProvider) private var themeProvider
    
    private let title: String
    private let subtitle: String?
    private let systemImage: String?
    private let content: () -> Content
    
    public init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: themeProvider.theme.spacing.md) {
            // Cabeçalho da seção
            sectionHeader
            
            // Conteúdo da seção
            VStack(spacing: themeProvider.theme.spacing.sm) {
                content()
            }
        }
        .padding(.horizontal, themeProvider.theme.spacing.lg)
    }
    
    @ViewBuilder
    private var sectionHeader: some View {
        HStack(spacing: themeProvider.theme.spacing.sm) {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .font(themeProvider.theme.typography.titleMedium)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
            }
            
            VStack(alignment: .leading, spacing: themeProvider.theme.spacing.xs) {
                Text(title)
                    .font(themeProvider.theme.typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(themeProvider.theme.typography.bodySmall)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, themeProvider.theme.spacing.sm)
    }
}

#Preview("Settings Section") {
    ScrollView {
        VStack(spacing: 24) {
            SettingsSection(
                title: "Conta",
                subtitle: "Gerir subscrição e pagamentos",
                systemImage: "creditcard.circle"
            ) {
                SettingsRow(
                    title: "Plano Atual",
                    subtitle: "Funcionalidades básicas",
                    systemImage: "crown",
                    value: "Plano Gratuito"
                )
                
                SettingsRow(
                    title: "Upgrade para Premium",
                    subtitle: "Desbloquear todas as funcionalidades",
                    systemImage: "star.circle",
                    onTap: {}
                )
            }
            
            SettingsSection(
                title: "Dados",
                subtitle: "Backup e sincronização",
                systemImage: "externaldrive.connected.to.line.below"
            ) {
                SettingsRow(
                    title: "Backup Automático",
                    subtitle: "Guardar listas automaticamente",
                    systemImage: "icloud.and.arrow.up",
                    isOn: .constant(true)
                )
                
                SettingsRow(
                    title: "Sincronização iCloud",
                    subtitle: "Sincronizar entre dispositivos",
                    systemImage: "icloud",
                    isOn: .constant(false)
                )
            }
        }
        .padding(.vertical)
    }
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}
