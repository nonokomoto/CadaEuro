import SwiftUI
import CadaEuroKit

/// Componente para selecionar um período (mês e ano) para visualização de estatísticas
public struct PeriodPicker: View {
    @Environment(\.themeProvider) private var themeProvider
    @Environment(\.dismiss) private var dismiss
    
    /// Mês selecionado (1-12)
    @Binding private var selectedMonth: Int
    
    /// Ano selecionado
    @Binding private var selectedYear: Int
    
    /// Ano atual para validação
    private let currentYear: Int
    
    /// Mês atual para validação
    private let currentMonth: Int
    
    /// Estado de animação para transições
    @State private var animateSelection: Bool = false
    
    /// Nomes dos meses em português
    private let monthNames = [
        "Janeiro", "Fevereiro", "Março", "Abril", 
        "Maio", "Junho", "Julho", "Agosto",
        "Setembro", "Outubro", "Novembro", "Dezembro"
    ]
    
    /// Anos disponíveis para seleção (2020 até o ano atual)
    private var availableYears: [Int] {
        Array((2020...currentYear).reversed())
    }
    
    /// Inicializador do componente
    /// - Parameters:
    ///   - selectedMonth: Binding para o mês selecionado (1-12)
    ///   - selectedYear: Binding para o ano selecionado
    public init(selectedMonth: Binding<Int>, selectedYear: Binding<Int>) {
        self._selectedMonth = selectedMonth
        self._selectedYear = selectedYear
        
        let calendar = Calendar.current
        let currentDate = Date()
        self.currentYear = calendar.component(.year, from: currentDate)
        self.currentMonth = calendar.component(.month, from: currentDate)
    }
    
    public var body: some View {
        VStack(spacing: themeProvider.theme.spacing.lg) {
            headerView
            
            Divider()
                .padding(.horizontal, themeProvider.theme.spacing.lg)
            
            pickerContent
                .padding(.top, themeProvider.theme.spacing.sm)
            
            Spacer()
            
            buttonRow
                .padding(.bottom, themeProvider.theme.spacing.lg)
        }
        .padding(.top, themeProvider.theme.spacing.xl)
        .background(themeProvider.theme.colors.cadaEuroBackground)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Seletor de período")
        .accessibilityHint("Selecione o mês e ano para visualização de estatísticas")
    }
    
    /// Cabeçalho do seletor de período
    private var headerView: some View {
        Text("Selecionar Período")
            .font(themeProvider.theme.typography.titleMedium)
            .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
            .padding(.horizontal, themeProvider.theme.spacing.lg)
            .accessibilityAddTraits(.isHeader)
    }
    
    /// Conteúdo principal do picker com seletores de mês e ano
    private var pickerContent: some View {
        VStack(spacing: themeProvider.theme.spacing.xl) {
            // Seletor de mês
            VStack(alignment: .leading, spacing: themeProvider.theme.spacing.xs) {
                Text("Mês")
                    .font(themeProvider.theme.typography.bodySmall)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                    .padding(.leading, themeProvider.theme.spacing.lg)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: themeProvider.theme.spacing.sm) {
                        ForEach(0..<monthNames.count, id: \.self) { index in
                            monthButton(month: index + 1, name: monthNames[index])
                        }
                    }
                    .padding(.horizontal, themeProvider.theme.spacing.lg)
                }
            }
            
            // Seletor de ano
            VStack(alignment: .leading, spacing: themeProvider.theme.spacing.xs) {
                Text("Ano")
                    .font(themeProvider.theme.typography.bodySmall)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                    .padding(.leading, themeProvider.theme.spacing.lg)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: themeProvider.theme.spacing.sm) {
                        ForEach(availableYears, id: \.self) { year in
                            yearButton(year: year)
                        }
                    }
                    .padding(.horizontal, themeProvider.theme.spacing.lg)
                }
            }
        }
    }
    
    /// Botão para seleção de mês
    private func monthButton(month: Int, name: String) -> some View {
        let isSelected = month == selectedMonth
        let isDisabled = isDateInFuture(month: month, year: selectedYear)
        
        return Button(action: {
            if !isDisabled {
                withAnimation(themeProvider.theme.animation.standard) {
                    selectedMonth = month
                    animateSelection = true
                }
                
                // Reseta a animação após um breve período
                DispatchQueue.main.asyncAfter(deadline: .now() + themeProvider.theme.animation.shortDuration) {
                    animateSelection = false
                }
                
                HapticManager.shared.feedback(.light)
            }
        }) {
            Text(name)
                .font(themeProvider.theme.typography.bodyMedium)
                .foregroundColor(isSelected 
                                ? themeProvider.theme.colors.cadaEuroAccent 
                                : isDisabled 
                                    ? themeProvider.theme.colors.cadaEuroTextTertiary
                                    : themeProvider.theme.colors.cadaEuroTextPrimary)
                .padding(.vertical, themeProvider.theme.spacing.xs)
                .padding(.horizontal, themeProvider.theme.spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: themeProvider.theme.border.smallButtonRadius)
                        .fill(isSelected 
                              ? themeProvider.theme.colors.cadaEuroAccent.opacity(0.1) 
                              : themeProvider.theme.colors.cadaEuroComponentBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: themeProvider.theme.border.smallButtonRadius)
                        .stroke(isSelected ? themeProvider.theme.colors.cadaEuroAccent : Color.clear, 
                                lineWidth: themeProvider.theme.border.standardBorderWidth)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected && animateSelection ? themeProvider.theme.animation.updatedTotalScale : 1.0)
        .disabled(isDisabled)
        .accessibilityLabel("Mês \(name)")
        .accessibilityValue(isSelected ? "Selecionado" : "")
        .accessibilityHint(isDisabled ? "Período futuro não disponível" : "")
    }
    
    /// Botão para seleção de ano
    private func yearButton(year: Int) -> some View {
        let isSelected = year == selectedYear
        
        return Button(action: {
            withAnimation(themeProvider.theme.animation.standard) {
                selectedYear = year
                
                // Validar se o mês selecionado é válido para o novo ano
                if isDateInFuture(month: selectedMonth, year: year) {
                    if year == currentYear {
                        selectedMonth = currentMonth
                    } else {
                        selectedMonth = 12
                    }
                }
                
                animateSelection = true
            }
            
            // Reseta a animação após um breve período
            DispatchQueue.main.asyncAfter(deadline: .now() + themeProvider.theme.animation.shortDuration) {
                animateSelection = false
            }
            
            HapticManager.shared.feedback(.light)
        }) {
            Text("\(year)")
                .font(themeProvider.theme.typography.bodyMedium)
                .foregroundColor(isSelected 
                                ? themeProvider.theme.colors.cadaEuroAccent 
                                : themeProvider.theme.colors.cadaEuroTextPrimary)
                .padding(.vertical, themeProvider.theme.spacing.xs)
                .padding(.horizontal, themeProvider.theme.spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: themeProvider.theme.border.smallButtonRadius)
                        .fill(isSelected 
                              ? themeProvider.theme.colors.cadaEuroAccent.opacity(0.1) 
                              : themeProvider.theme.colors.cadaEuroComponentBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: themeProvider.theme.border.smallButtonRadius)
                        .stroke(isSelected ? themeProvider.theme.colors.cadaEuroAccent : Color.clear, 
                                lineWidth: themeProvider.theme.border.standardBorderWidth)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected && animateSelection ? themeProvider.theme.animation.updatedTotalScale : 1.0)
        .accessibilityLabel("Ano \(year)")
        .accessibilityValue(isSelected ? "Selecionado" : "")
    }
    
    /// Botões de confirmação e cancelamento
    private var buttonRow: some View {
        HStack(spacing: themeProvider.theme.spacing.lg) {
            Button(action: {
                HapticManager.shared.feedback(.medium)
                dismiss()
            }) {
                Text("Cancelar")
                    .font(themeProvider.theme.typography.bodyMedium)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
                    .padding(.vertical, themeProvider.theme.spacing.xs)
                    .padding(.horizontal, themeProvider.theme.spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: themeProvider.theme.border.smallButtonRadius)
                            .fill(themeProvider.theme.colors.cadaEuroComponentBackground)
                    )
            }
            .accessibilityHint("Cancela a seleção e fecha o seletor de período")
            
            Button(action: {
                HapticManager.shared.feedback(.success)
                dismiss()
            }) {
                Text("Confirmar")
                    .font(themeProvider.theme.typography.bodyMedium)
                    .foregroundColor(.white)
                    .padding(.vertical, themeProvider.theme.spacing.xs)
                    .padding(.horizontal, themeProvider.theme.spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: themeProvider.theme.border.smallButtonRadius)
                            .fill(themeProvider.theme.colors.cadaEuroAccent)
                    )
            }
            .accessibilityHint("Confirma a seleção e aplica o período escolhido")
        }
        .padding(.horizontal, themeProvider.theme.spacing.lg)
    }
    
    /// Verifica se a data selecionada está no futuro
    private func isDateInFuture(month: Int, year: Int) -> Bool {
        if year > currentYear {
            return true
        }
        if year == currentYear && month > currentMonth {
            return true
        }
        return false
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var selectedMonth = 5
        @State private var selectedYear = 2025
        @State private var showPicker = true
        
        var body: some View {
            ZStack {
                themeProvider.theme.colors.cadaEuroBackground
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Estatísticas: \(monthNames[selectedMonth-1]) \(selectedYear)")
                        .font(themeProvider.theme.typography.titleMedium)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                        .padding()
                    
                    Button("Selecionar Período") {
                        showPicker = true
                    }
                    .padding()
                }
                
                if showPicker {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showPicker = false
                        }
                    
                    PeriodPicker(selectedMonth: $selectedMonth, selectedYear: $selectedYear)
                        .frame(height: 400)
                        .cornerRadius(themeProvider.theme.border.cardRadius)
                        .padding(.horizontal, themeProvider.theme.spacing.lg)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .withThemeProvider(ThemeProvider())
        }
        
        private var themeProvider: ThemeProvider {
            ThemeProvider()
        }
        
        private var monthNames: [String] {
            [
                "Janeiro", "Fevereiro", "Março", "Abril", 
                "Maio", "Junho", "Julho", "Agosto",
                "Setembro", "Outubro", "Novembro", "Dezembro"
            ]
        }
    }
    
    return PreviewWrapper()
}
