import SwiftUI
import CadaEuroKit

/// View principal para visualização de estatísticas
/// Fase 3A: Foundation - UI pura com dados mock
public struct StatsView: View {
    @Environment(\.themeProvider) private var themeProvider
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = StatsViewModel()
    
    // MARK: - State Management
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showingPeriodPicker = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.isEmpty {
                    emptyStateView
                } else {
                    statsContentView
                }
            }
            .background(themeProvider.theme.colors.cadaEuroBackground)
            .navigationTitle("Estatísticas")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $showingPeriodPicker) {
                periodPickerSheet
            }
            .task {
                await viewModel.loadStats(month: selectedMonth, year: selectedYear)
            }
            .onChange(of: selectedMonth) { _, newMonth in
                Task {
                    await viewModel.loadStats(month: newMonth, year: selectedYear)
                }
            }
            .onChange(of: selectedYear) { _, newYear in
                Task {
                    await viewModel.loadStats(month: selectedMonth, year: newYear)
                }
            }
        }
        .logLifecycle(viewName: "StatsView")
    }
    
    // MARK: - Loading View
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: themeProvider.theme.spacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Um segundo...")
                .font(themeProvider.theme.typography.bodyMedium)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack {
            Spacer()
            
            EmptyStateView(type: .statistics)
                .padding(themeProvider.theme.spacing.lg)
            
            Spacer()
        }
    }
    
    // MARK: - Stats Content View
    
    @ViewBuilder
    private var statsContentView: some View {
        ScrollView {
            VStack(spacing: themeProvider.theme.spacing.xl) {
                // Header com período selecionado
                periodHeaderSection
                
                // Métricas principais
                mainMetricsSection
                
                // Gráfico de evolução
                chartSection
                
                Spacer(minLength: themeProvider.theme.spacing.xl)
            }
            .padding(themeProvider.theme.spacing.lg)
        }
        .refreshable {
            await viewModel.refreshStats(month: selectedMonth, year: selectedYear)
        }
    }
    
    // MARK: - Period Header Section
    
    @ViewBuilder
    private var periodHeaderSection: some View {
        VStack(spacing: themeProvider.theme.spacing.md) {
           
            HStack(spacing: themeProvider.theme.spacing.lg) {
                // Botão anterior
                Button(action: { navigateToPreviousMonth() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
                                .overlay(
                                    Circle()
                                        .stroke(themeProvider.theme.colors.cadaEuroAccent.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
                
                // Período atual (clicável para picker)
                Button(action: { showingPeriodPicker = true }) {
                    Text(PeriodPicker.formatPeriod(month: selectedMonth, year: selectedYear))
                        .font(themeProvider.theme.typography.titleLarge)
                        .fontWeight(.semibold)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                        .padding(.horizontal, themeProvider.theme.spacing.lg)
                        .padding(.vertical, themeProvider.theme.spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: themeProvider.theme.border.buttonRadius)
                                .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
                            
                        )
                }
                .buttonStyle(.plain)
                
                // Botão próximo
                Button(action: { navigateToNextMonth() }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(canNavigateToNext() ? themeProvider.theme.colors.cadaEuroAccent : themeProvider.theme.colors.cadaEuroTextSecondary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
                                .overlay(
                                    Circle()
                                        .stroke((canNavigateToNext() ? themeProvider.theme.colors.cadaEuroAccent : themeProvider.theme.colors.cadaEuroTextSecondary).opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
                .disabled(!canNavigateToNext())
            }
        }
    }
    
    // MARK: - Main Metrics Section
    
    @ViewBuilder
    private var mainMetricsSection: some View {
        VStack(spacing: themeProvider.theme.spacing.lg) {
            // Métricas em grid 2x2
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: themeProvider.theme.spacing.md),
                GridItem(.flexible(), spacing: themeProvider.theme.spacing.md)
            ], spacing: themeProvider.theme.spacing.lg) {
                // Total gasto
                StatsMetricsCard(
                    title: "Total Gasto",
                    value: viewModel.totalSpent.asStatsPrice,
                    icon: "eurosign.circle.fill",
                    iconColor: themeProvider.theme.colors.cadaEuroAccent
                )
                
                // Número de listas
                StatsMetricsCard(
                    title: "Listas Criadas",
                    value: String(viewModel.totalLists),
                    icon: "list.bullet.circle.fill",
                    iconColor: .green
                )
                
                // Média por lista
                StatsMetricsCard(
                    title: "Média por Lista",
                    value: viewModel.averagePerList.asStatsPrice,
                    icon: "chart.bar.fill",
                    iconColor: .orange
                )
                
                // Total de itens
                StatsMetricsCard(
                    title: "Total de Itens",
                    value: String(viewModel.totalItems),
                    icon: "cart.fill",
                    iconColor: .purple
                )
            }
        }
    }
    
    // MARK: - Chart Section
    
    @ViewBuilder
    private var chartSection: some View {
        BarChartView(
            title: "Evolução Mensal",
            dataPoints: viewModel.chartData,
            primaryColor: themeProvider.theme.colors.cadaEuroAccent
        )
    }
    
    // MARK: - Period Picker Sheet
    
    @ViewBuilder
    private var periodPickerSheet: some View {
        PeriodPicker(
            selectedMonth: $selectedMonth,
            selectedYear: $selectedYear,
            isPresented: $showingPeriodPicker
        ) { month, year in
            selectedMonth = month
            selectedYear = year
            Task {
                await viewModel.loadStats(month: month, year: year)
            }
        }
    }
    
    // MARK: - Toolbar Content
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Fechar") {
                dismiss()
            }
        }
        #else
        ToolbarItem(placement: .cancellationAction) {
            Button("Fechar") {
                dismiss()
            }
        }
        #endif
    }
    
    // MARK: - Navigation Methods
    
    private func canNavigateToNext() -> Bool {
        let calendar = Calendar.current
        let currentComponents = DateComponents(year: selectedYear, month: selectedMonth, day: 1)
        
        if let currentDate = calendar.date(from: currentComponents),
           let nextDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            return nextDate <= Date()
        }
        return false
    }
    
    private func navigateToPreviousMonth() {
        let calendar = Calendar.current
        let currentComponents = DateComponents(year: selectedYear, month: selectedMonth, day: 1)
        
        if let currentDate = calendar.date(from: currentComponents),
           let previousDate = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            selectedMonth = calendar.component(.month, from: previousDate)
            selectedYear = calendar.component(.year, from: previousDate)
        }
    }
    
    private func navigateToNextMonth() {
        let calendar = Calendar.current
        let currentComponents = DateComponents(year: selectedYear, month: selectedMonth, day: 1)
        
        if let currentDate = calendar.date(from: currentComponents),
           let nextDate = calendar.date(byAdding: .month, value: 1, to: currentDate),
           nextDate <= Date() { // Não permitir navegar para o futuro
            selectedMonth = calendar.component(.month, from: nextDate)
            selectedYear = calendar.component(.year, from: nextDate)
        }
    }
}

// MARK: - Previews

#Preview("Stats View - Empty") {
    StatsView()
        .themeProvider(.preview)
}

#Preview("Stats View - With Data") {
    let view = StatsView()
    // Note: O ViewModel carrega dados mock automaticamente
    return view.themeProvider(.preview)
}

#Preview("Stats View - Dark Mode") {
    StatsView()
        .themeProvider(.darkPreview)
        .preferredColorScheme(.dark)
}
