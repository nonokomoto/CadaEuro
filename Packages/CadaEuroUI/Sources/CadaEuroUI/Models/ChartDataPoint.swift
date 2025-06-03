import Foundation

/// Estrutura para representar dados do gráfico
public struct ChartDataPoint: Identifiable {
    public let id = UUID()
    public let label: String
    public let value: Double
    public let date: Date
    
    public init(label: String, value: Double, date: Date) {
        self.label = label
        self.value = value
        self.date = date
    }
}
