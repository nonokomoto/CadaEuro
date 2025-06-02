import Foundation

/// Erros específicos do gravador de voz
public enum VoiceRecorderError: LocalizedError, Sendable, Equatable {
    case permissionDenied
    case recordingFailed
    case recognitionNotAvailable
    case processingFailed
    case networkUnavailable
    case recordingTooShort
    
    public var errorDescription: String? {
        switch self {
        case .permissionDenied: 
            return "Permissão do microfone necessária"
        case .recordingFailed: 
            return "Falha na gravação"
        case .recognitionNotAvailable: 
            return "Reconhecimento de fala não disponível"
        case .processingFailed: 
            return "Falha ao processar o áudio"
        case .networkUnavailable: 
            return "Sem ligação à internet"
        case .recordingTooShort:
            return "Gravação muito curta (mínimo 1 segundo)"
        }
    }
    
    /// Converte para um código de erro genérico que pode ser usado pelo CaptureError
    public var errorCode: String {
        switch self {
        case .permissionDenied: return "permission_denied"
        case .recordingFailed: return "recording_failed"
        case .recognitionNotAvailable: return "recognition_not_available"
        case .processingFailed: return "processing_failed"
        case .networkUnavailable: return "network_unavailable"
        case .recordingTooShort: return "recording_too_short"
        }
    }
    
    /// Cria um VoiceRecorderError a partir de um código de erro
    public static func from(code: String) -> VoiceRecorderError? {
        switch code {
        case "permission_denied": return .permissionDenied
        case "recording_failed": return .recordingFailed
        case "recognition_not_available": return .recognitionNotAvailable
        case "processing_failed": return .processingFailed
        case "network_unavailable": return .networkUnavailable
        case "recording_too_short": return .recordingTooShort
        default: return nil
        }
    }
}
