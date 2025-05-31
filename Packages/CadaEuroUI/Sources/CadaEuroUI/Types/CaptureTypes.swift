import SwiftUI

/// Tipos de erro de captura com recovery strategies
public enum CaptureError: LocalizedError, Sendable {
    case cameraPermissionDenied
    case cameraUnavailable
    case microphonePermissionDenied
    case microphoneUnavailable
    case ocrFailed
    case speechRecognitionFailed
    case networkUnavailable
    
    public var title: String {
        switch self {
        case .cameraPermissionDenied: return "Permissão da Câmara"
        case .cameraUnavailable: return "Câmara Indisponível"
        case .microphonePermissionDenied: return "Permissão do Microfone"
        case .microphoneUnavailable: return "Microfone Indisponível"
        case .ocrFailed: return "Reconhecimento Falhou"
        case .speechRecognitionFailed: return "Voz não Reconhecida"
        case .networkUnavailable: return "Sem Ligação"
        }
    }
    
    public var suggestion: String {
        switch self {
        case .cameraPermissionDenied:
            return "Permita o acesso à câmara nas Definições para usar o scanner."
        case .cameraUnavailable:
            return "A câmara não está disponível neste momento."
        case .microphonePermissionDenied:
            return "Permita o acesso ao microfone nas Definições para usar comando de voz."
        case .microphoneUnavailable:
            return "O microfone não está disponível neste momento."
        case .ocrFailed:
            return "Não consegui ler a etiqueta. Tente aproximar ou melhorar a iluminação."
        case .speechRecognitionFailed:
            return "Não consegui entender. Fale claramente e tente novamente."
        case .networkUnavailable:
            return "Verifique a sua ligação à internet e tente novamente."
        }
    }
    
    public var icon: String {
        switch self {
        case .cameraPermissionDenied, .cameraUnavailable: return "camera.fill"
        case .microphonePermissionDenied, .microphoneUnavailable: return "mic.slash.fill"
        case .ocrFailed: return "doc.text.viewfinder"
        case .speechRecognitionFailed: return "waveform.path.ecg"
        case .networkUnavailable: return "wifi.slash"
        }
    }
    
    public var fallbackText: String {
        switch self {
        case .ocrFailed, .speechRecognitionFailed:
            return "Adicionar Manualmente"
        default:
            return "Entrada Manual"
        }
    }
}

/// Estados de captura para feedback visual
public enum CaptureState: Sendable, Equatable {
    case idle
    case active
    case processing
    case success
    case error(CaptureError)
    
    public var isProcessing: Bool {
        switch self {
        case .processing:
            return true
        default:
            return false
        }
    }
    
    public var hasError: Bool {
        if case .error = self {
            return true
        }
        return false
    }
}
