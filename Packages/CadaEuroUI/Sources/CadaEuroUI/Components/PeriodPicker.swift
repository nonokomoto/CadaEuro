import SwiftUI
import CadaEuroKit

/// Picker de período premium para navegação temporal nas estatísticas
public struct PeriodPicker: View {
    @Environment(\.themeProvider) private var themeProvider
    
    // MARK: - Bindings
    @Binding private var selectedMonth: Int
    @Binding private var selectedYear: Int
    @Binding private var isPresented: Bool
    
    // MARK: - Properties
    private let onConfirm: (Int, Int) -> Void
    
    // MARK: - State
    @State private var tempMonth: Int
    @State private var tempYear: Int
    
    // MARK: - Constants
    private let currentDate = Date()
    private let calendar = Calendar.current
    
    public init(
        selectedMonth: Binding<Int>,
        selectedYear: Binding<Int>,
        isPresented: Binding<Bool>,
        onConfirm: @escaping (Int, Int) -> Void
    ) {
        self._selectedMonth = selectedMonth
        self._selectedYear = selectedYear
        self._isPresented = isPresented
        self.onConfirm = onConfirm
        self._tempMonth = State(initialValue: selectedMonth.wrappedValue)
        self._tempYear = State(initialValue: selectedYear.wrappedValue)
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: themeProvider.theme.spacing.xl) {
                // Header com período selecionado
                periodHeader
                
                // Pickers lado a lado
                pickerSection
                
                Spacer()
                
                // Botões de ação
                actionButtons
            }
            .padding(themeProvider.theme.spacing.lg)
            .background(themeProvider.theme.colors.cadaEuroBackground)
            .navigationTitle("Selecionar Período")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        cancelSelection()
                    }
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                }
            }
        }
        .onAppear {
            // Sincronizar valores temporários com seleção atual
            tempMonth = selectedMonth
            tempYear = selectedYear
        }
        .accessibilityLabel("Seletor de período")
        .accessibilityHint("Escolha mês e ano para visualizar estatísticas")
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var periodHeader: some View {
        VStack(spacing: themeProvider.theme.spacing.sm) {
            Text("Período Selecionado")
                .font(themeProvider.theme.typography.bodyMedium)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
            
            Text(formattedPeriod)
                .font(themeProvider.theme.typography.titleLarge)
                .fontWeight(.semibold)
                .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                .animation(themeProvider.theme.animation.quick, value: tempMonth)
                .animation(themeProvider.theme.animation.quick, value: tempYear)
        }
        .padding(.top, themeProvider.theme.spacing.lg)
    }
    
    @ViewBuilder
    private var pickerSection: some View {
        HStack(spacing: themeProvider.theme.spacing.lg) {
            // Picker de Mês
            VStack(spacing: themeProvider.theme.spacing.sm) {
                Text("Mês")
                    .font(themeProvider.theme.typography.bodyMedium)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                
                Picker("Mês", selection: $tempMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text(monthName(for: month))
                            .tag(month)
                    }
                }
                #if os(iOS)
                .pickerStyle(.wheel)
                #else
                .pickerStyle(.menu)
                #endif
                .frame(height: 120)
            }
            
            // Picker de Ano
            VStack(spacing: themeProvider.theme.spacing.sm) {
                Text("Ano")
                    .font(themeProvider.theme.typography.bodyMedium)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                
                Picker("Ano", selection: $tempYear) {
                    ForEach(availableYears, id: \.self) { year in
                        Text(String(year))
                            .tag(year)
                    }
                }
                #if os(iOS)
                .pickerStyle(.wheel)
                #else
                .pickerStyle(.menu)
                #endif
                .frame(height: 120)
            }
        }
        .padding(.horizontal, themeProvider.theme.spacing.sm)
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: themeProvider.theme.spacing.lg) {
            ActionButton(
                "Confirmar",
                systemImage: "checkmark",
                type: .primary,
                isEnabled: isValidDate
            ) {
                confirmSelection()
            }
            
            ActionButton(
                "Cancelar",
                type: .secondary
            ) {
                cancelSelection()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var formattedPeriod: String {
        // ✅ USAR DateExtensions: Formatação específica para StatsView
        let date = dateFromSelection(month: tempMonth, year: tempYear)
        return date.asMonthYear
    }
    
    private var availableYears: [Int] {
        let currentYear = calendar.component(.year, from: currentDate)
        return Array(2020...currentYear).reversed()
    }
    
    private var isValidDate: Bool {
        // ✅ USAR DateExtensions: Validação para estatísticas
        let date = dateFromSelection(month: tempMonth, year: tempYear)
        return date.isValidForStats
    }
    
    // MARK: - Methods
    
    private func monthName(for month: Int) -> String {
        let date = dateFromSelection(month: month, year: tempYear)
        // ✅ USAR DateExtensions: Formatação consistente com resto da app
        return date.asMonthYear.components(separatedBy: " ").first ?? "Janeiro"
    }
    
    /// ✅ USAR DateExtensions: Helper para criar Date a partir de mês/ano
    private func dateFromSelection(month: Int, year: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: 1)
        return calendar.date(from: components) ?? currentDate
    }
    
    /// ✅ USAR DateExtensions: Range calculations para filtros
    private func getDateRange(for month: Int, year: Int) -> (start: Date, end: Date) {
        let date = dateFromSelection(month: month, year: year)
        return date.monthRange
    }
    
    private func confirmSelection() {
        guard isValidDate else { return }
        
        // ✅ SwiftUI-Only: Sem UIImpactFeedbackGenerator
        // Feedback háptico será adicionado via SensoryFeedback quando disponível
        
        onConfirm(tempMonth, tempYear)
        isPresented = false
    }
    
    private func cancelSelection() {
        // Restaurar valores originais
        tempMonth = selectedMonth
        tempYear = selectedYear
        isPresented = false
    }
}

// MARK: - Preview Data

extension PeriodPicker {
    /// Dados de preview para desenvolvimento
    private static let previewDate = Date()
    private static let previewCalendar = Calendar.current
    
    static var previewMonth: Int {
        previewCalendar.component(.month, from: previewDate)
    }
    
    static var previewYear: Int {
        previewCalendar.component(.year, from: previewDate)
    }
}

// MARK: - Previews

#Preview("Period Picker") {
    @Previewable @State var selectedMonth = PeriodPicker.previewMonth
    @Previewable @State var selectedYear = PeriodPicker.previewYear
    @Previewable @State var isPresented = true
    
    PeriodPicker(
        selectedMonth: $selectedMonth,
        selectedYear: $selectedYear,
        isPresented: $isPresented
    ) { month, year in
        print("Selected: \(month)/\(year)")
    }
    .themeProvider(.preview)
}

#Preview("Period Picker Dark") {
    @Previewable @State var selectedMonth = 3
    @Previewable @State var selectedYear = 2024
    @Previewable @State var isPresented = true
    
    PeriodPicker(
        selectedMonth: $selectedMonth,
        selectedYear: $selectedYear,
        isPresented: $isPresented
    ) { month, year in
        print("Selected: \(month)/\(year)")
    }
    .themeProvider(.darkPreview)
    .preferredColorScheme(.dark)
}

#Preview("Period Picker in Sheet") {
    @Previewable @State var selectedMonth = PeriodPicker.previewMonth
    @Previewable @State var selectedYear = PeriodPicker.previewYear
    @Previewable @State var showingPicker = false
    
    VStack {
        Button("Abrir Seletor de Período") {
            showingPicker = true
        }
        .foregroundColor(.blue)
        
        Spacer()
        
        Text("Período atual: \(selectedMonth)/\(selectedYear)")
            .font(.title2)
            .padding()
    }
    .sheet(isPresented: $showingPicker) {
        PeriodPicker(
            selectedMonth: $selectedMonth,
            selectedYear: $selectedYear,
            isPresented: $showingPicker
        ) { month, year in
            selectedMonth = month
            selectedYear = year
            print("Updated period: \(month)/\(year)")
        }
    }
    .themeProvider(.preview)
}

// MARK: - StatsView Integration Helpers

/// Extensões específicas para integração com StatsView
public extension PeriodPicker {
    
    /// ✅ USAR DateExtensions: Cria PeriodPicker com data atual
    ///
    /// - Returns: PeriodPicker configurado para mês/ano atual
    /// - Use Case: Inicialização padrão em StatsView
    static func currentPeriod(
        isPresented: Binding<Bool>,
        onConfirm: @escaping (Int, Int) -> Void
    ) -> PeriodPicker {
        let now = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        return PeriodPicker(
            selectedMonth: .constant(currentMonth),
            selectedYear: .constant(currentYear),
            isPresented: isPresented,
            onConfirm: onConfirm
        )
    }
    
    /// ✅ USAR DateExtensions: Valida se período é adequado para estatísticas
    ///
    /// - Parameters:
    ///   - month: Mês a validar
    ///   - year: Ano a validar
    /// - Returns: Bool indicando se período é válido para stats
    /// - Use Case: Validação em StatsView antes de queries
    static func isValidPeriodForStats(month: Int, year: Int) -> Bool {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month, day: 1)
        guard let date = calendar.date(from: components) else { return false }
        
        return date.isValidForStats
    }
    
    /// ✅ USAR DateExtensions: Obtém range de datas para período
    ///
    /// - Parameters:
    ///   - month: Mês selecionado
    ///   - year: Ano selecionado
    /// - Returns: Tupla com início e fim do mês
    /// - Use Case: Filtros de dados em StatsView
    static func dateRange(for month: Int, year: Int) -> (start: Date, end: Date)? {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month, day: 1)
        guard let date = calendar.date(from: components) else { return nil }
        
        return date.monthRange
    }
    
    /// ✅ USAR DateExtensions: Formata período para display
    ///
    /// - Parameters:
    ///   - month: Mês a formatar
    ///   - year: Ano a formatar
    /// - Returns: String formatada "Janeiro 2025"
    /// - Use Case: Headers em StatsView
    static func formatPeriod(month: Int, year: Int) -> String {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month, day: 1)
        guard let date = calendar.date(from: components) else { return "Período inválido" }
        
        return date.asMonthYear
    }
}
