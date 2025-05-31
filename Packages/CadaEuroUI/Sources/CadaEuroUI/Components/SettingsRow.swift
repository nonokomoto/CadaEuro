import SwiftUI

/// Tipos de configuração disponíveis na aplicação CadaEuro
public enum SettingsRowType: String, CaseIterable, Sendable {
    // 1. Conta
    case managePlan = "crown.fill"
    case restorePurchases = "arrow.clockwise"
    
    // 2. Dados  
    case exportLists = "square.and.arrow.up"
    case importData = "square.and.arrow.down"
    case iCloudBackup = "icloud"
    case autoBackup = "icloud.circle"
    
    // 3. Personalização
    case textSize = "textformat.size"
    case currency = "eurosign.circle"
    case notifications = "bell"
    case highContrast = "circle.lefthalf.filled"
    
    // 4. Acessibilidade
    case accessibleTextSize = "accessibility"
    case reduceMotion = "motion.sensor.off"
    
    // 5. Suporte
    case about = "info.circle"
    
    public var systemImage: String {
        return self.rawValue
    }
    
    public var title: String {
        switch self {
        case .managePlan: return "Gerir plano PRO"
        case .restorePurchases: return "Restaurar compras"
        case .exportLists: return "Exportar listas"
        case .importData: return "Importar dados"
        case .iCloudBackup: return "Backup iCloud"
        case .autoBackup: return "Backup automático"
        case .textSize: return "Tamanho do texto"
        case .currency: return "Moeda"
        case .notifications: return "Notificações"
        case .highContrast: return "Alto contraste"
        case .accessibleTextSize: return "Texto acessível"
        case .reduceMotion: return "Reduzir movimento"
        case .about: return "Sobre"
        }
    }
    
    public var subtitle: String? {
        switch self {
        case .managePlan: return "Acesso a funcionalidades premium"
        case .restorePurchases: return "Recuperar compras anteriores"
        case .exportLists: return "Criar backup das suas listas"
        case .importData: return "Importar listas guardadas"
        case .iCloudBackup: return "Backup manual no iCloud Drive"
        case .autoBackup: return "Sincronização automática"
        case .textSize: return "Pequeno, médio ou grande"
        case .currency: return "Euro (padrão)"
        case .notifications: return "Alertas e lembretes"
        case .highContrast: return "Melhor visibilidade"
        case .accessibleTextSize: return "Suporte Dynamic Type"
        case .reduceMotion: return "Animações simplificadas"
        case .about: return "Versão e informações"
        }
    }
    
    public var accessibilityHint: String {
        switch self {
        case .managePlan: return "Abre gestão de subscrição PRO"
        case .restorePurchases: return "Restaura compras realizadas anteriormente"
        case .exportLists: return "Cria ficheiro de backup das listas"
        case .importData: return "Importa dados de backup"
        case .iCloudBackup: return "Cria backup manual no iCloud"
        case .autoBackup: return "Activa ou desactiva backup automático"
        case .textSize: return "Ajusta tamanho das fontes"
        case .currency: return "Escolhe moeda de visualização"
        case .notifications: return "Gere permissões de notificação"
        case .highContrast: return "Activa modo de alto contraste"
        case .accessibleTextSize: return "Configura acessibilidade de texto"
        case .reduceMotion: return "Reduz animações para acessibilidade"
        case .about: return "Mostra informações da aplicação"
        }
    }
}

/// Estilo visual da linha de configuração
public enum SettingsRowStyle: Sendable {
    case navigation    // Com chevron para drill-down
    case toggle       // Com switch toggle
    case action       // Botão simples sem navegação
    case picker       // Com valor atual e chevron
    
    public var hasChevron: Bool {
        switch self {
        case .navigation, .picker: return true
        case .toggle, .action: return false
        }
    }
}

/// Linha de configuração premium para CadaEuro
public struct SettingsRow: View {
    @Environment(\.themeProvider) private var themeProvider
    
    private let type: SettingsRowType
    private let style: SettingsRowStyle
    private let value: String?
    private let isOn: Binding<Bool>?
    private let action: () -> Void
    
    @State private var isPressed = false
    
    // MARK: - Initializers
    
    /// Inicialização para row de navegação
    public init(
        type: SettingsRowType,
        style: SettingsRowStyle = .navigation,
        action: @escaping () -> Void
    ) {
        self.type = type
        self.style = style
        self.value = nil
        self.isOn = nil
        self.action = action
    }
    
    /// Inicialização para row com toggle
    public init(
        type: SettingsRowType,
        isOn: Binding<Bool>,
        action: @escaping () -> Void = {}
    ) {
        self.type = type
        self.style = .toggle
        self.value = nil
        self.isOn = isOn
        self.action = action
    }
    
    /// Inicialização para row com valor (picker)
    public init(
        type: SettingsRowType,
        value: String,
        action: @escaping () -> Void
    ) {
        self.type = type
        self.style = .picker
        self.value = value
        self.isOn = nil
        self.action = action
    }
    
    public var body: some View {
        Button(action: handleAction) {
            HStack(spacing: themeProvider.theme.spacing.lg) {
                // Ícone - sempre com cor normal
                Image(systemName: type.systemImage)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
                    .frame(width: 24, height: 24)
                
                // Conteúdo principal - sempre com cor normal
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.title)
                        .font(themeProvider.theme.typography.bodyLarge)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                        .multilineTextAlignment(.leading)
                    
                    if let subtitle = type.subtitle {
                        Text(subtitle)
                            .font(themeProvider.theme.typography.bodySmall)
                            .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                // Elemento trailing
                trailingElement
            }
            .padding(.vertical, themeProvider.theme.spacing.sm)
            .padding(.horizontal, themeProvider.theme.spacing.lg)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: themeProvider.theme.border.cardRadius))
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(themeProvider.theme.animation.quick, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        // ✅ REMOVIDO .disabled() - agora controlamos no handleAction()
        .onLongPressGesture(minimumDuration: 0) { pressing in
            if style != .toggle {
                isPressed = pressing
            }
        } perform: {}
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(type.accessibilityHint)
        .accessibilityAddTraits(accessibilityTraits)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var trailingElement: some View {
        switch style {
        case .navigation, .action:
            if style.hasChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextTertiary)
            }
            
        case .toggle:
            if let isOn = isOn {
                Toggle("", isOn: isOn)
                    .tint(themeProvider.theme.colors.cadaEuroAccent)
                    .scaleEffect(0.9)
                    // ✅ Sem .disabled() aqui - Toggle deve funcionar normalmente
            }
            
        case .picker:
            HStack(spacing: themeProvider.theme.spacing.xs) {
                if let value = value {
                    Text(value)
                        .font(themeProvider.theme.typography.bodyMedium)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextTertiary)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var backgroundColor: Color {
        // ✅ Background sempre normal - não depende de estado disabled
        if isPressed {
            return themeProvider.theme.colors.cadaEuroComponentBackground.opacity(0.8)
        }
        return themeProvider.theme.colors.cadaEuroComponentBackground
    }
    
    private var accessibilityLabel: String {
        var label = type.title
        
        if style == .toggle, let isOn = isOn {
            label += isOn.wrappedValue ? ", ativado" : ", desativado"
        } else if style == .picker, let value = value {
            label += ", \(value)"
        }
        
        return label
    }
    
    private var accessibilityTraits: AccessibilityTraits {
        switch style {
        case .navigation, .picker: 
            return [.isButton]  // ✅ SwiftUI correto
        case .toggle: 
            return []  // Toggle já tem traits próprios
        case .action: 
            return [.isButton]  // ✅ SwiftUI correto
        }
    }
    
    // MARK: - Methods
    
    private func handleAction() {
        // ✅ Apenas previne execução da ação, não desabilita visualmente
        guard style != .toggle else { return }
        action()
    }
}

// MARK: - Previews

#Preview("Settings Rows - Navigation") {
    VStack(spacing: 12) {
        SettingsRow(type: .managePlan) {
            print("Manage plan tapped")
        }
        
        SettingsRow(type: .exportLists) {
            print("Export lists tapped")
        }
        
        SettingsRow(type: .about) {
            print("About tapped")
        }
    }
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("Settings Rows - Toggle") {
    @Previewable @State var notifications = true
    @Previewable @State var autoBackup = false
    @Previewable @State var highContrast = true
    
    VStack(spacing: 12) {
        SettingsRow(type: .notifications, isOn: $notifications)
        SettingsRow(type: .autoBackup, isOn: $autoBackup)
        SettingsRow(type: .highContrast, isOn: $highContrast)
    }
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("Settings Rows - Picker") {
    VStack(spacing: 12) {
        SettingsRow(type: .textSize, value: "Médio") {
            print("Text size picker")
        }
        
        SettingsRow(type: .currency, value: "EUR (€)") {
            print("Currency picker")
        }
    }
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("Settings Rows - iCloud Backup") {
    @Previewable @State var autoBackup = true
    
    VStack(spacing: 12) {
        SettingsRow(type: .iCloudBackup) {
            print("Manual iCloud backup")
        }
        
        SettingsRow(type: .autoBackup, isOn: $autoBackup)
        
        SettingsRow(type: .exportLists) {
            print("Export backup file")
        }
        
        SettingsRow(type: .importData) {
            print("Import backup data")
        }
    }
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("Settings Rows - Dark Mode") {
    @Previewable @State var notifications = false
    @Previewable @State var highContrast = true
    
    VStack(spacing: 12) {
        SettingsRow(type: .managePlan) {
            print("Manage plan")
        }
        
        SettingsRow(type: .notifications, isOn: $notifications)
        
        SettingsRow(type: .textSize, value: "Grande") {
            print("Text size")
        }
        
        SettingsRow(type: .highContrast, isOn: $highContrast)
    }
    .padding()
    .background(ThemeProvider.darkPreview.theme.colors.cadaEuroBackground)
    .themeProvider(.darkPreview)
    .preferredColorScheme(.dark)
}
