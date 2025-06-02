import SwiftUI

/// PreferenceKey para capturar a posição de botões de captura
struct CaptureButtonPositionKey: PreferenceKey {
    static let defaultValue: [String: CGRect] = [:]
    
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

/// ViewModifier para capturar a posição de um botão de captura
struct CaptureButtonPositionReader: ViewModifier {
    let id: String
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: CaptureButtonPositionKey.self,
                            value: [id: geometry.frame(in: .global)]
                        )
                }
            )
    }
}

extension View {
    /// Adiciona um leitor de posição para botões de captura
    func captureButtonPosition(id: String) -> some View {
        modifier(CaptureButtonPositionReader(id: id))
    }
}
