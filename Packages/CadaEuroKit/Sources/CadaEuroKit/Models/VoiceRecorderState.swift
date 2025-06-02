import Foundation

/// Estados do gravador de voz
public enum VoiceRecorderState: String, CaseIterable {
    case idle        // Pronto para gravar
    case recording   // Gravando áudio
    case processing  // Processando gravação
    case completed   // Concluído
    case error      // Erro durante gravação
    
    public var isActive: Bool {
        switch self {
        case .recording, .processing:
            return true
        case .idle, .completed, .error:
            return false
        }
    }
    
    public var canStartRecording: Bool {
        return self == .idle
    }
    
    public var canStopRecording: Bool {
        return self == .recording
    }
}
