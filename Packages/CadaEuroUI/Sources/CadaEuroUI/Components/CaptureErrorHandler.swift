import SwiftUI

/// Sistema centralizado de error recovery para componentes de captura
public struct CaptureErrorHandler: View {
    @Environment(\.themeProvider) private var themeProvider
    
    private let error: CaptureError
    private let onRetry: () -> Void
    private let onCancel: () -> Void
    private let onFallback: (() -> Void)?
    
    public init(
        error: CaptureError,
        onRetry: @escaping () -> Void,
        onCancel: @escaping () -> Void,
        onFallback: (() -> Void)? = nil
    ) {
        self.error = error
        self.onRetry = onRetry
        self.onCancel = onCancel
        self.onFallback = onFallback
    }
    
    public var body: some View {
        VStack(spacing: themeProvider.theme.spacing.lg) {
            // Ícone de erro
            Image(systemName: error.icon)
                .font(.system(size: 48))
                .foregroundColor(themeProvider.theme.colors.cadaEuroError)
            
            // Mensagem
            VStack(spacing: themeProvider.theme.spacing.sm) {
                Text(error.title)
                    .font(themeProvider.theme.typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                
                Text(error.suggestion)
                    .font(themeProvider.theme.typography.bodyMedium)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Ações
            VStack(spacing: themeProvider.theme.spacing.md) {
                ActionButton(
                    "Tentar Novamente",
                    systemImage: "arrow.clockwise",
                    type: .primary
                ) {
                    onRetry()
                }
                
                if let onFallback = onFallback {
                    ActionButton(
                        error.fallbackText,
                        systemImage: "pencil",
                        type: .secondary
                    ) {
                        onFallback()
                    }
                }
                
                ActionButton(
                    "Cancelar",
                    type: .secondary
                ) {
                    onCancel()
                }
            }
        }
        .padding(themeProvider.theme.spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: themeProvider.theme.border.cardRadius)
                .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
        )
        .padding(themeProvider.theme.spacing.lg)
    }
}

// MARK: - View Extension for Easy Integration

public extension View {
    /// Modifier para mostrar error handler como overlay
    func captureErrorHandler(
        error: CaptureError?,
        onRetry: @escaping () -> Void,
        onCancel: @escaping () -> Void,
        onFallback: (() -> Void)? = nil
    ) -> some View {
        self.overlay {
            if let error = error {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            onCancel()
                        }
                    
                    CaptureErrorHandler(
                        error: error,
                        onRetry: onRetry,
                        onCancel: onCancel,
                        onFallback: onFallback
                    )
                }
                .transition(.opacity)
            }
        }
        .animation(ThemeProvider.preview.theme.animation.spring, value: error)
    }
}

// MARK: - Previews

#Preview("Camera Permission Error") {
    VStack {
        Text("Scanner View")
            .font(.largeTitle)
    }
    .captureErrorHandler(
        error: .cameraPermissionDenied,
        onRetry: {
            print("Retry camera permission")
        },
        onCancel: {
            print("Cancel")
        },
        onFallback: {
            print("Use manual input")
        }
    )
    .themeProvider(.preview)
}

#Preview("OCR Failed Error") {
    VStack {
        Text("Scanner View")
            .font(.largeTitle)
    }
    .captureErrorHandler(
        error: .ocrFailed,
        onRetry: {
            print("Retry OCR")
        },
        onCancel: {
            print("Cancel")
        },
        onFallback: {
            print("Manual input fallback")
        }
    )
    .themeProvider(.darkPreview)
    .preferredColorScheme(.dark)
}

#Preview("Speech Recognition Error") {
    VStack {
        Text("Voice Input View")
            .font(.largeTitle)
    }
    .captureErrorHandler(
        error: .speechRecognitionFailed,
        onRetry: {
            print("Retry speech recognition")
        },
        onCancel: {
            print("Cancel")
        },
        onFallback: {
            print("Switch to manual input")
        }
    )
    .themeProvider(.preview)
}

#Preview("Network Error") {
    VStack {
        Text("LLM Processing View")
            .font(.largeTitle)
    }
    .captureErrorHandler(
        error: .networkUnavailable,
        onRetry: {
            print("Retry network request")
        },
        onCancel: {
            print("Cancel")
        }
    )
    .themeProvider(.preview)
}
