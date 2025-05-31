import SwiftUI
import CadaEuroKit  

/// Botão de captura minimalista para métodos CadaEuro
public struct CaptureButton: View {
    @Environment(\.themeProvider) private var themeProvider
    
    private let method: CaptureMethod
    private let isActive: Bool
    private let action: () -> Void
    
    private let onLongPress: (() -> Void)?  
    
    @State private var isPressed = false
    
    public init(
        method: CaptureMethod,
        isActive: Bool = false,
        action: @escaping () -> Void,
        onLongPress: (() -> Void)? = nil  // ✅ Novo parâmetro opcional
    ) {
        self.method = method
        self.isActive = isActive
        self.action = action
        self.onLongPress = onLongPress
    }
    
    public var body: some View {
        Button(action: action) {
            ZStack {
                // Background circle
                Circle()
                    .fill(backgroundGradient)
                    .frame(width: 64, height: 64)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .shadow(
                        color: shadowColor,
                        radius: isActive ? 8 : 4,
                        x: 0,
                        y: isActive ? 4 : 2
                    )
                
                // Ícone - ✅ AGORA: Usa properties do CaptureMethod centralizado
                Image(systemName: method.systemImage)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(iconColor)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .animation(themeProvider.theme.animation.quick, value: isPressed)
        .animation(themeProvider.theme.animation.spring, value: isActive)
        // ✅ Long press APENAS para microfone
        .if(method == .voice) { view in
            view.onLongPressGesture(minimumDuration: 0) { pressing in
                isPressed = pressing
                // ✅ Trigger long press callback apenas para voz
                if pressing {
                    onLongPress?()
                }
            } perform: {}
        }
        // ✅ Scanner/Manual: apenas feedback visual sem long press
        .if(method != .voice) { view in
            view.onTapGesture {
                // Tap simples executa a action
            }
            .onLongPressGesture(minimumDuration: 0) { pressing in
                // Apenas feedback visual
                isPressed = pressing
            } perform: {}
        }
        // ✅ AGORA: Usa accessibility properties do CaptureMethod centralizado
        .accessibilityLabel(method.title)
        .accessibilityHint(method.accessibilityHint)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
    
    // MARK: - Computed Properties
    
    private var backgroundGradient: LinearGradient {
        // ✅ AGORA: Usa accentColor do CaptureMethod centralizado
        let baseColor = isActive ? method.accentColor : themeProvider.theme.colors.cadaEuroAccent
        let opacity = isActive ? 0.2 : 0.1
        
        return LinearGradient(
            gradient: Gradient(colors: [
                baseColor.opacity(opacity),
                baseColor.opacity(opacity * 0.6)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var iconColor: Color {
        if isActive {
            // ✅ AGORA: Usa accentColor do CaptureMethod centralizado
            return method.accentColor
        }
        return themeProvider.theme.colors.cadaEuroAccent
    }
    
    private var shadowColor: Color {
        if isActive {
            // ✅ AGORA: Usa accentColor do CaptureMethod centralizado
            return method.accentColor.opacity(0.3)
        }
        return themeProvider.theme.colors.cadaEuroTextTertiary.opacity(0.2)
    }
}

// MARK: - View Extensions
private extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview("Capture Buttons Minimal") {
    VStack(spacing: 24) {
        HStack(spacing: 32) {
            CaptureButton(method: .scanner, isActive: true) {
                print("Scanner tapped")
            }
            
            CaptureButton(method: .voice) {
                print("Voice tapped")
            }
        }
        
        CaptureButton(method: .manual) {
            print("Manual tapped")
        }
    }
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("Capture Button Dark") {
    HStack(spacing: 32) {
        CaptureButton(method: .scanner, isActive: true) {
            print("Scanner tapped")
        }
        
        CaptureButton(method: .voice) {
            print("Voice tapped")
        }
        
        CaptureButton(method: .manual) {
            print("Manual tapped")
        }
    }
    .padding()
    .background(ThemeProvider.darkPreview.theme.colors.cadaEuroBackground)
    .themeProvider(.darkPreview)
    .preferredColorScheme(.dark)
}

#Preview("Capture Button with Long Press") {
    VStack(spacing: 24) {
        CaptureButton(method: .voice, isActive: true) {
            print("Voice tap")
        } onLongPress: {
            print("Voice long press - start recording") // ✅ Integração
        }
        
    }
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}
