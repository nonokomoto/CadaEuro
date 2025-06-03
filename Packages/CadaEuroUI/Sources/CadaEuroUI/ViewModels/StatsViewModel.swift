import SwiftUI
import CadaEuroKit

/// ViewModel para StatsView com gestão de mock data
@MainActor
public final class StatsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var totalSpent: Double = 0.0
    @Published public var totalLists: Int = 0
    @Published public var totalItems: Int = 0
    @Published public var averagePerList: Double = 0.0
    @Published public var chartData: [ChartDataPoint] = []
    
    // MARK: - Private Properties
    private var currentMonth: Int = 1
    private var currentYear: Int = 2024
    
    // MARK: - Computed Properties
    
    public var isEmpty: Bool {
        totalLists == 0
    }
    
    // MARK: - Initialization
    
    public init() {
        // Initialize with current month/year
        let now = Date()
        let calendar = Calendar.current
        currentMonth = calendar.component(.month, from: now)
        currentYear = calendar.component(.year, from: now)
    }
    
    // MARK: - Data Loading
    
    public func loadStats(month: Int, year: Int) async {
        CadaEuroLogger.info("Loading stats for \(month)/\(year)", category: .userInteraction)
        
        isLoading = true
        errorMessage = nil
        currentMonth = month
        currentYear = year
        
        do {
            // TODO: Fase 5 - Implementar queries SwiftData reais
            // let statsData = try await statisticsManager.fetchStats(month: month, year: year)
            
            // Mock data baseado no período
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
            loadMockStats(month: month, year: year)
            
            CadaEuroLogger.info("Loaded stats: \(totalLists) lists, €\(totalSpent)", category: .userInteraction)
            
        } catch {
            CadaEuroLogger.error("Failed to load stats", error: error, category: .error)
            errorMessage = "Erro ao carregar estatísticas"
        }
        
        isLoading = false
    }
    
    public func refreshStats(month: Int, year: Int) async {
        await loadStats(month: month, year: year)
    }
    
    // MARK: - Mock Data Generation
    
    private func loadMockStats(month: Int, year: Int) {
        // Gerar dados mock baseados no período selecionado
        let currentDate = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
        // Se for o mês atual, usar dados mais realistas
        if month == currentMonth && year == currentYear {
            loadCurrentMonthMockData()
        } else if month == currentMonth - 1 && year == currentYear {
            // Mês anterior - dados completos
            loadPreviousMonthMockData()
        } else {
            // Outros períodos - dados variáveis
            loadRandomPeriodMockData(month: month, year: year)
        }
        
        // Calcular média por lista
        if totalLists > 0 {
            averagePerList = totalSpent / Double(totalLists)
        } else {
            averagePerList = 0.0
        }
    }
    
    private func loadCurrentMonthMockData() {
        // Dados para o mês atual (parciais)
        totalLists = 3
        totalItems = 24
        totalSpent = 87.45
        
        // Gerar dados do gráfico para o mês atual
        generateCurrentMonthChartData()
    }
    
    private func loadPreviousMonthMockData() {
        // Dados para o mês anterior (completos)
        totalLists = 8
        totalItems = 67
        totalSpent = 234.89
        
        // Gerar dados do gráfico para o mês anterior
        generatePreviousMonthChartData()
    }
    
    private func loadRandomPeriodMockData(month: Int, year: Int) {
        // Dados variáveis baseados no mês/ano
        let seed = month + year * 12
        let random = Double(seed % 100) / 100.0
        
        // Gerar dados pseudo-aleatórios mas consistentes
        totalLists = Int(random * 10) + 1 // 1-11 listas
        totalItems = totalLists * (4 + Int(random * 8)) // 4-12 itens por lista em média
        totalSpent = Double(totalItems) * (3.0 + random * 7.0) // €3-10 por item em média
        
        // Arredondar valor total
        totalSpent = round(totalSpent * 100) / 100
        
        // Gerar dados do gráfico para períodos aleatórios
        generateRandomPeriodChartData(month: month, year: year)
    }
    
    // MARK: - Computed Stats Helpers
    
    /// Retorna se há dados suficientes para mostrar estatísticas
    public func hasValidData() -> Bool {
        return totalLists > 0 && totalSpent > 0
    }
    
    /// Retorna o período formatado para display
    public func formattedPeriod() -> String {
        return PeriodPicker.formatPeriod(month: currentMonth, year: currentYear)
    }
    
    /// Retorna descrição de comparação com período anterior
    public func comparisonDescription() -> String {
        // TODO: Fase 5 - Implementar comparação real com dados do período anterior
        return "Sem dados de comparação disponíveis"
    }
    
    // MARK: - Chart Data Generation
    
    private func generateCurrentMonthChartData() {
        // Dados do gráfico para o mês atual (3 listas)
        let calendar = Calendar.current
        let now = Date()
        
        chartData = [
            ChartDataPoint(
                label: "Lista 1",
                value: 25.30,
                date: calendar.date(byAdding: .day, value: -15, to: now) ?? now
            ),
            ChartDataPoint(
                label: "Lista 2",
                value: 34.20,
                date: calendar.date(byAdding: .day, value: -8, to: now) ?? now
            ),
            ChartDataPoint(
                label: "Lista 3",
                value: 27.95,
                date: calendar.date(byAdding: .day, value: -2, to: now) ?? now
            )
        ]
    }
    
    private func generatePreviousMonthChartData() {
        // Dados do gráfico para o mês anterior (8 listas)
        let calendar = Calendar.current
        let now = Date()
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        
        chartData = [
            ChartDataPoint(label: "Lista 1", value: 45.60, date: previousMonth),
            ChartDataPoint(label: "Lista 2", value: 23.45, date: previousMonth),
            ChartDataPoint(label: "Lista 3", value: 67.80, date: previousMonth),
            ChartDataPoint(label: "Lista 4", value: 12.30, date: previousMonth),
            ChartDataPoint(label: "Lista 5", value: 89.20, date: previousMonth),
            ChartDataPoint(label: "Lista 6", value: 34.75, date: previousMonth),
            ChartDataPoint(label: "Lista 7", value: 56.40, date: previousMonth),
            ChartDataPoint(label: "Lista 8", value: 28.90, date: previousMonth)
        ]
    }
    
    private func generateRandomPeriodChartData(month: Int, year: Int) {
        // Gerar dados do gráfico para períodos aleatórios
        let seed = month + year * 12
        let listCount = max(1, (seed % 10) + 1) // 1-10 listas
        let calendar = Calendar.current
        
        var data: [ChartDataPoint] = []
        let baseDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
        
        for i in 0..<listCount {
            let randomValue = Double((seed + i) % 100) * 2.0 + 10.0 // €10-€210
            let roundedValue = round(randomValue * 100) / 100
            
            data.append(ChartDataPoint(
                label: "Lista \(i + 1)",
                value: roundedValue,
                date: calendar.date(byAdding: .day, value: i * 3, to: baseDate) ?? baseDate
            ))
        }
        
        chartData = data
    }
    
    // MARK: - Error Handling
    
    public func handleError(_ error: Error) {
        CadaEuroLogger.error("StatsViewModel error occurred", error: error, category: .error)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            errorMessage = error.localizedDescription
        }
        
        // Clear error after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.errorMessage = nil
            }
        }
    }
}
