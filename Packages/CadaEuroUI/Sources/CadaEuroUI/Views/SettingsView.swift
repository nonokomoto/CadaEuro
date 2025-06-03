import SwiftUI
import CadaEuroKit

/// View principal das definições da aplicação CadaEuro
///
/// Esta view implementa as 5 seções principais de configurações:
/// - Conta: Gestão de perfil e subscrição
/// - Dados: Backup, sincronização e privacidade
/// - Personalização: Tema, idioma e preferências visuais
/// - Acessibilidade: VoiceOver, tamanho de texto e contrastes
/// - Suporte: FAQ, contacto e informações legais
///
/// Utiliza dados mock através do SettingsViewModel até implementação completa.
public struct SettingsView: View {
    @Environment(\.themeProvider) private var themeProvider
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingThemePicker = false
    @State private var showingLanguagePicker = false
    @State private var showingTextSizePicker = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                // Background
                themeProvider.theme.colors.cadaEuroBackground
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    loadingView
                } else {
                    mainContent
                }
            }
            .navigationTitle("Definições")
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $showingThemePicker) {
                themePicker
            }
            .sheet(isPresented: $showingLanguagePicker) {
                languagePicker
            }
            .sheet(isPresented: $showingTextSizePicker) {
                textSizePicker
            }
            .alert("Erro", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .onAppear {
            viewModel.loadSettings()
        }
    }
    
    // MARK: - Main Content
    
    @ViewBuilder
    private var mainContent: some View {
        ScrollView {
            LazyVStack(spacing: themeProvider.theme.spacing.xl) {
                accountSection
                dataSection
                personalizationSection
                accessibilitySection
                supportSection
            }
            .padding(.vertical, themeProvider.theme.spacing.lg)
        }
    }
    
    // MARK: - Loading View
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: themeProvider.theme.spacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(themeProvider.theme.colors.cadaEuroAccent)
            
            Text("A carregar definições...")
                .font(themeProvider.theme.typography.bodyMedium)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
        }
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Button("Concluído") {
                dismiss()
            }
            .font(themeProvider.theme.typography.bodyMedium)
            .fontWeight(.medium)
            .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
        }
    }
    
    // MARK: - Account Section
    
    @ViewBuilder
    private var accountSection: some View {
        SettingsSection(
            title: "Conta",
            subtitle: "Gerir subscrição e pagamentos",
            systemImage: "creditcard.circle"
        ) {
            SettingsRow(
                title: "Plano Atual",
                subtitle: viewModel.currentPlan.description,
                systemImage: "crown",
                value: viewModel.currentPlan.displayName
            )
            
            if !viewModel.hasPremiumSubscription {
                SettingsRow(
                    title: "Upgrade para Premium",
                    subtitle: "Desbloquear todas as funcionalidades",
                    systemImage: "star.circle",
                    onTap: {
                        viewModel.upgradeToPremium()
                    }
                )
            }
            
            if viewModel.hasPremiumSubscription {
                SettingsRow(
                    title: "Renovação",
                    subtitle: "Próxima cobrança",
                    systemImage: "calendar",
                    value: formatDate(viewModel.subscriptionExpiryDate)
                )
                
                SettingsRow(
                    title: "Gerir Subscrição",
                    subtitle: "Cancelar ou alterar plano",
                    systemImage: "gear",
                    onTap: {
                        // TODO: Implementar gestão de subscrição
                    }
                )
            }
        }
    }
    
    // MARK: - Data Section
    
    @ViewBuilder
    private var dataSection: some View {
        SettingsSection(
            title: "Dados",
            subtitle: "Backup, sincronização e privacidade",
            systemImage: "externaldrive.connected.to.line.below"
        ) {
            SettingsRow(
                title: "Backup Automático",
                subtitle: "Guardar listas automaticamente no iCloud",
                systemImage: "icloud.and.arrow.up",
                isOn: Binding(
                    get: { viewModel.isAutoBackupEnabled },
                    set: { _ in viewModel.toggleAutoBackup() }
                )
            )
            
            SettingsRow(
                title: "Sincronização iCloud",
                subtitle: "Sincronizar dados entre dispositivos",
                systemImage: "icloud",
                isOn: Binding(
                    get: { viewModel.isiCloudSyncEnabled },
                    set: { _ in viewModel.toggleiCloudSync() }
                )
            )
            
            SettingsRow(
                title: "Última Sincronização",
                systemImage: "clock",
                value: formatRelativeDate(viewModel.lastSyncDate)
            )
            
            SettingsRow(
                title: "Sincronizar Agora",
                subtitle: "Forçar sincronização manual",
                systemImage: "arrow.clockwise",
                onTap: {
                    viewModel.syncNow()
                }
            )
            
            SettingsRow(
                title: "Limpar Cache",
                subtitle: "Tamanho atual: \(viewModel.cacheSize)",
                systemImage: "trash",
                onTap: {
                    viewModel.clearCache()
                }
            )
            
            SettingsRow(
                title: "Privacidade",
                subtitle: "Gerir permissões e dados pessoais",
                systemImage: "lock.shield",
                onTap: {
                    // TODO: Implementar configurações de privacidade
                }
            )
        }
    }
    
    // MARK: - Personalization Section
    
    @ViewBuilder
    private var personalizationSection: some View {
        SettingsSection(
            title: "Personalização",
            subtitle: "Tema, idioma e preferências visuais",
            systemImage: "paintbrush"
        ) {
            SettingsRow(
                title: "Tema",
                subtitle: "Escolher aparência da aplicação",
                systemImage: "moon.circle",
                onTap: {
                    showingThemePicker = true
                }
            )
            
            SettingsRow(
                title: "Idioma",
                subtitle: "Alterar idioma da interface",
                systemImage: "globe",
                onTap: {
                    showingLanguagePicker = true
                }
            )
            
            SettingsRow(
                title: "Moeda",
                subtitle: "Moeda predefinida para preços",
                systemImage: "eurosign.circle",
                onTap: {
                    // TODO: Implementar picker de moeda
                }
            )
            
            SettingsRow(
                title: "Formato de Números",
                subtitle: "Como os números são apresentados",
                systemImage: "textformat.123",
                onTap: {
                    // TODO: Implementar picker de formato
                }
            )
        }
    }
    
    // MARK: - Accessibility Section
    
    @ViewBuilder
    private var accessibilitySection: some View {
        SettingsSection(
            title: "Acessibilidade",
            subtitle: "VoiceOver, texto e contrastes",
            systemImage: "accessibility"
        ) {
            SettingsRow(
                title: "Tamanho do Texto",
                subtitle: "Ajustar tamanho para melhor leitura",
                systemImage: "textformat.size",
                onTap: {
                    showingTextSizePicker = true
                }
            )
            
            SettingsRow(
                title: "Alto Contraste",
                subtitle: "Aumentar contraste para melhor visibilidade",
                systemImage: "circle.lefthalf.filled",
                isOn: Binding(
                    get: { viewModel.isHighContrastEnabled },
                    set: { _ in viewModel.toggleHighContrast() }
                )
            )
            
            SettingsRow(
                title: "Reduzir Movimento",
                subtitle: "Diminuir animações e transições",
                systemImage: "rectangle.arrowtriangle.2.inward",
                isOn: Binding(
                    get: { viewModel.isReduceMotionEnabled },
                    set: { _ in viewModel.toggleReduceMotion() }
                )
            )
            
            SettingsRow(
                title: "VoiceOver",
                subtitle: viewModel.isVoiceOverEnabled ? "Ativo" : "Inativo",
                systemImage: "speaker.wave.2",
                value: viewModel.isVoiceOverEnabled ? "Ligado" : "Desligado"
            )
        }
    }
    
    // MARK: - Support Section
    
    @ViewBuilder
    private var supportSection: some View {
        SettingsSection(
            title: "Suporte",
            subtitle: "Ajuda, contacto e informações",
            systemImage: "questionmark.circle"
        ) {
            SettingsRow(
                title: "FAQ",
                subtitle: "Perguntas frequentes",
                systemImage: "questionmark.bubble",
                onTap: {
                    viewModel.openFAQ()
                }
            )
            
            SettingsRow(
                title: "Contactar Suporte",
                subtitle: "Enviar feedback ou reportar problema",
                systemImage: "envelope",
                onTap: {
                    viewModel.openContact()
                }
            )
            
            SettingsRow(
                title: "Avaliar Aplicação",
                subtitle: "Partilhe a sua opinião na App Store",
                systemImage: "star",
                onTap: {
                    // TODO: Implementar link para App Store
                }
            )
            
            SettingsRow(
                title: "Versão",
                systemImage: "info.circle",
                value: "\(viewModel.appVersion) (\(viewModel.buildNumber))"
            )
            
            SettingsRow(
                title: "Tamanho da Aplicação",
                systemImage: "externaldrive",
                value: viewModel.appSize
            )
            
            SettingsRow(
                title: "Termos de Utilização",
                subtitle: "Ler condições de uso",
                systemImage: "doc.text",
                onTap: {
                    // TODO: Implementar navegação para termos
                }
            )
            
            SettingsRow(
                title: "Política de Privacidade",
                subtitle: "Como tratamos os seus dados",
                systemImage: "lock.doc",
                onTap: {
                    // TODO: Implementar navegação para política
                }
            )
        }
    }
    
    // MARK: - Pickers
    
    @ViewBuilder
    private var themePicker: some View {
        NavigationView {
            List {
                ForEach(ThemeMode.allCases, id: \.rawValue) { theme in
                    Button(action: {
                        viewModel.updateTheme(theme)
                        showingThemePicker = false
                    }) {
                        HStack {
                            Text(theme.displayName)
                                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                            
                            Spacer()
                            
                            if viewModel.selectedTheme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tema")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Concluído") {
                        showingThemePicker = false
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var languagePicker: some View {
        NavigationView {
            List {
                ForEach(AppLanguage.allCases, id: \.rawValue) { language in
                    Button(action: {
                        viewModel.updateLanguage(language)
                        showingLanguagePicker = false
                    }) {
                        HStack {
                            Text(language.displayName)
                                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                            
                            Spacer()
                            
                            if viewModel.selectedLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Idioma")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Concluído") {
                        showingLanguagePicker = false
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var textSizePicker: some View {
        NavigationView {
            List {
                ForEach(TextSize.allCases, id: \.rawValue) { size in
                    Button(action: {
                        viewModel.updateTextSize(size)
                        showingTextSizePicker = false
                    }) {
                        HStack {
                            Text(size.displayName)
                                .font(.system(size: 16 * size.scaleFactor))
                                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                            
                            Spacer()
                            
                            if viewModel.textSize == size {
                                Image(systemName: "checkmark")
                                    .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tamanho do Texto")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Concluído") {
                        showingTextSizePicker = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "pt_PT")
        return formatter.string(from: date)
    }
    
    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "pt_PT")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview("Settings View") {
    SettingsView()
        .themeProvider(.preview)
}
