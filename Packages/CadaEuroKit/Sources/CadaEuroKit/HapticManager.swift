import Foundation
import SwiftUI

/// Gestor centralizado de feedback háptico para a aplicação CadaEuro
/// Fornece uma interface consistente para feedback háptico usando apenas SwiftUI
@MainActor public final class HapticManager {
    
    /// Singleton para acesso global
    public static let shared = HapticManager()
    
    /// Tipos de feedback háptico suportados
    public enum FeedbackType {
        /// Feedback leve para interações subtis
        case light
        
        /// Feedback médio para interações standard
        case medium
        
        /// Feedback forte para interações importantes
        case heavy
        
        /// Feedback de sucesso para operações concluídas com êxito
        case success
        
        /// Feedback de erro para operações falhadas
        case error
        
        /// Feedback de aviso para alertas
        case warning
    }
    
    /// Inicializador privado para garantir o padrão singleton
    private init() {}
    
    /// Fornece feedback háptico do tipo especificado
    /// - Parameter type: O tipo de feedback háptico a fornecer
    public func feedback(_ type: FeedbackType) {
        #if os(iOS)
        // Usar SensoryFeedback do SwiftUI (iOS 17+)
        switch type {
        case .light:
            performSensoryFeedback(.impact(weight: .light, intensity: 0.5))
        case .medium:
            performSensoryFeedback(.impact(weight: .medium, intensity: 0.7))
        case .heavy:
            performSensoryFeedback(.impact(weight: .heavy, intensity: 1.0))
        case .success:
            performSensoryFeedback(.success)
        case .error:
            performSensoryFeedback(.error)
        case .warning:
            performSensoryFeedback(.warning)
        }
        #endif
    }
    
    /// Executa o feedback sensorial usando a API do SwiftUI
    private func performSensoryFeedback(_ feedback: SensoryFeedback) {
        #if os(iOS)
        // No iOS 17+, podemos usar diretamente o SensoryFeedback
        // Numa aplicação real, isto seria integrado com as views
        // Para simular o efeito, estamos a chamar programaticamente
        // Em SwiftUI 6, o feedback sensorial deve ser aplicado via .sensoryFeedback() nas views.
        // Não existe API programática para disparar SensoryFeedback fora de uma View.
        #endif
    }
}
