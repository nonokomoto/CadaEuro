import SwiftUI

/// Tipo de ação disponível nos botões CadaEuro
public enum ActionType: String, CaseIterable {
    case primary = "primary"
    case secondary = "secondary"
    case destructive = "destructive"
    
    // MARK: - Methods with MainActor isolation
    @MainActor
    func textColor(for themeProvider: ThemeProvider) -> Color {
        switch self {
        case .primary: return themeProvider.theme.colors.cadaEuroComponentBackground
        case .secondary: return themeProvider.theme.colors.cadaEuroAccent
        case .destructive: return themeProvider.theme.colors.cadaEuroComponentBackground
        }
    }
    
    @MainActor
    func backgroundColor(for themeProvider: ThemeProvider) -> Color {
        switch self {
        case .primary: return themeProvider.theme.colors.cadaEuroAccent
        case .secondary: return Color.clear
        case .destructive: return themeProvider.theme.colors.cadaEuroError
        }
    }
    
    @MainActor
    func borderColor(for themeProvider: ThemeProvider) -> Color {
        switch self {
        case .primary: return Color.clear
        case .secondary: return themeProvider.theme.colors.cadaEuroAccent
        case .destructive: return Color.clear
        }
    }
}

/// Botão de ação premium para CadaEuro
public struct ActionButton: View {
    @Environment(\.themeProvider) private var themeProvider
    
    private let title: String
    private let systemImage: String?
    private let type: ActionType
    private let isEnabled: Bool
    private let action: () -> Void
    
    @State private var isPressed = false
    
    public init(
        _ title: String,
        systemImage: String? = nil,
        type: ActionType = .primary,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.type = type
        self.isEnabled = isEnabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: themeProvider.theme.spacing.sm) {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(themeProvider.theme.typography.bodyLarge)
                }
                
                Text(title)
                    .font(themeProvider.theme.typography.bodyLarge)
                    .fontWeight(.medium)
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity, minHeight: 48)
            .padding(.horizontal, themeProvider.theme.spacing.xl)
            .background(backgroundColor)
            .cornerRadius(themeProvider.theme.border.buttonRadius)
            .overlay(
                RoundedRectangle(cornerRadius: themeProvider.theme.border.buttonRadius)
                    .stroke(borderColor, lineWidth: type == .secondary ? 1 : 0)
            )
            .scaleEffect(isPressed ? themeProvider.theme.animation.pressedScale : 1.0)
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .onLongPressGesture(minimumDuration: 0) { pressing in
            withAnimation(themeProvider.theme.animation.quick) {
                isPressed = pressing
            }
            // ✅ SwiftUI-Only: Sem UIImpactFeedbackGenerator
            // Feedback háptico será adicionado via SensoryFeedback quando disponível
        } perform: {}
        .accessibilityLabel(title)
        
    }
    
    // MARK: - Computed Properties
    private var textColor: Color {
        isEnabled ? type.textColor(for: themeProvider) : themeProvider.theme.colors.cadaEuroTextTertiary
    }
    
    private var backgroundColor: Color {
        if !isEnabled {
            return themeProvider.theme.colors.cadaEuroDisabled
        }
        return type.backgroundColor(for: themeProvider)
    }
    
    private var borderColor: Color {
        isEnabled ? type.borderColor(for: themeProvider) : themeProvider.theme.colors.cadaEuroDisabled
    }
}

#Preview("Action Buttons") {
    VStack(spacing: 16) {
        ActionButton("Adicionar à Lista", systemImage: "plus", type: .primary) {
            print("Primary action")
        }
        
        ActionButton("Cancelar", type: .secondary) {
            print("Secondary action")
        }
        
        ActionButton("Eliminar", systemImage: "trash", type: .destructive) {
            print("Destructive action")
        }
        
        ActionButton("Disabled", type: .primary, isEnabled: false) {
            print("Won't execute")
        }
    }
    .padding()
        .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}
