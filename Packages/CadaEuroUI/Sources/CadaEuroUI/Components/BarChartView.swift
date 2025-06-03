import SwiftUI
import CadaEuroKit

/// Componente simples para exibir gráfico de barras com preços das listas
public struct BarChartView: View {
    @Environment(\.themeProvider) private var themeProvider
    
    // MARK: - Properties
    
    private let title: String
    private let dataPoints: [ChartDataPoint]
    private let primaryColor: Color
    
    // MARK: - Initialization
    
    public init(
        title: String,
        dataPoints: [ChartDataPoint],
        primaryColor: Color = .blue
    ) {
        self.title = title
        self.dataPoints = dataPoints
        self.primaryColor = primaryColor
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: themeProvider.theme.spacing.md) {
            // Header do gráfico
            VStack(alignment: .leading, spacing: themeProvider.theme.spacing.xs) {
                Text(title)
                    .font(themeProvider.theme.typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                
                if !dataPoints.isEmpty {
                    Text("Preços individuais de cada lista")
                        .font(themeProvider.theme.typography.bodySmall)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                }
            }
            
            // Conteúdo do gráfico
            if dataPoints.isEmpty {
                emptyStateView
            } else {
                barChartContent
            }
        }
        .padding(themeProvider.theme.spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: themeProvider.theme.border.cardRadius)
                .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: themeProvider.theme.border.cardRadius)
                        .stroke(themeProvider.theme.colors.cadaEuroSeparator, lineWidth: 0.5)
                )
        )
    }
    
    // MARK: - Empty State
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: themeProvider.theme.spacing.md) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 32))
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
            
            Text("Sem dados para exibir")
                .font(themeProvider.theme.typography.bodyMedium)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Bar Chart Content
    
    @ViewBuilder
    private var barChartContent: some View {
        GeometryReader { geometry in
            let maxValue = dataPoints.map(\.value).max() ?? 1
            let barWidth = min(60, (geometry.size.width - CGFloat(dataPoints.count - 1) * 8) / CGFloat(dataPoints.count))
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(dataPoints) { point in
                    VStack(spacing: themeProvider.theme.spacing.xs) {
                        // Valor acima da barra
                        Text(point.value.asStatsPrice)
                            .font(themeProvider.theme.typography.bodySmall)
                            .fontWeight(.medium)
                            .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                            .frame(height: 20)
                        
                        // Barra
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        primaryColor,
                                        primaryColor.opacity(0.7)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: barWidth)
                            .frame(height: max(8, (geometry.size.height - 40) * (point.value / maxValue)))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(primaryColor.opacity(0.3), lineWidth: 1)
                            )
                        
                        
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 200)
    }
}

// MARK: - Previews

#Preview("Bar Chart with Data") {
    BarChartView(
        title: "Preços das Listas",
        dataPoints: [
            ChartDataPoint(label: "Lista 1", value: 25.30, date: Date()),
            ChartDataPoint(label: "Lista 2", value: 67.30, date: Date()),
            ChartDataPoint(label: "Lista 3", value: 89.20, date: Date()),
            ChartDataPoint(label: "Lista 4", value: 45.50, date: Date()),
            ChartDataPoint(label: "Lista 5", value: 123.45, date: Date())
        ],
        primaryColor: .blue
    )
    .themeProvider(.preview)
    .padding()
}

#Preview("Empty Bar Chart") {
    BarChartView(
        title: "Sem Dados",
        dataPoints: [],
        primaryColor: .gray
    )
    .themeProvider(.preview)
    .padding()
}
