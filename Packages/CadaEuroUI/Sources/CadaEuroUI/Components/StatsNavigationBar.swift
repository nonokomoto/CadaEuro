import SwiftUI
import CadaEuroKit

/// Barra de navegação para mudança de período nas estatísticas
public struct StatsNavigationBar: View {
    @Environment(\.themeProvider) private var themeProvider
    
    // MARK: - Properties
    private let currentMonth: Int
    private let currentYear: Int
    private let onPreviousMonth: () -> Void
    private let onNextMonth: () -> Void
    private let onShowPicker: () -> Void
    
    public init(
        currentMonth: Int,
        currentYear: Int,
        onPreviousMonth: @escaping () -> Void,
        onNextMonth: @escaping () -> Void,
        onShowPicker: @escaping () -> Void
    ) {
        self.currentMonth = currentMonth
        self.currentYear = currentYear
        self.onPreviousMonth = onPreviousMonth
        self.onNextMonth = onNextMonth
        self.onShowPicker = onShowPicker
    }
    
    public var body: some View {
        HStack(spacing: themeProvider.theme.spacing.lg) {
            // Botão período anterior
            previousButton
            
            Spacer()
            
            // Período atual (clicável para mostrar picker)
            currentPeriodButton
            
            Spacer()
            
            // Botão próximo período
            nextButton
        }
        .padding(.horizontal, themeProvider.theme.spacing.md)
        .padding(.vertical, themeProvider.theme.spacing.sm)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var previousButton: some View {
        Button(action: onPreviousMonth) {
            HStack(spacing: themeProvider.theme.spacing.xs) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))
                
                Text("Anterior")
                    .font(themeProvider.theme.typography.bodySmall)
            }
            .foregroundColor(themeProvider.theme.colors.cadaEuroAccent)
            .padding(.horizontal, themeProvider.theme.spacing.md)
            .padding(.vertical, themeProvider.theme.spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: themeProvider.theme.border.buttonRadius)
                    .fill(themeProvider.theme.colors.cadaEuroAccent.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Período anterior")
    }
    
    @ViewBuilder
    private var currentPeriodButton: some View {
        Button(action: onShowPicker) {
            VStack(spacing: themeProvider.theme.spacing.xs) {
                Text(formattedPeriod)
                    .font(themeProvider.theme.typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                
                HStack(spacing: themeProvider.theme.spacing.xs) {
                    Text("Alterar período")
                        .font(themeProvider.theme.typography.caption)
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextTertiary)
                    
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextTertiary)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Período atual: \(formattedPeriod). Toque para alterar")
    }
    
    @ViewBuilder
    private var nextButton: some View {
        Button(action: onNextMonth) {
            HStack(spacing: themeProvider.theme.spacing.xs) {
                Text("Seguinte")
                    .font(themeProvider.theme.typography.bodySmall)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isNextButtonEnabled ? themeProvider.theme.colors.cadaEuroAccent : themeProvider.theme.colors.cadaEuroTextTertiary)
            .padding(.horizontal, themeProvider.theme.spacing.md)
            .padding(.vertical, themeProvider.theme.spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: themeProvider.theme.border.buttonRadius)
                    .fill(
                        isNextButtonEnabled 
                        ? themeProvider.theme.colors.cadaEuroAccent.opacity(0.1)
                        : themeProvider.theme.colors.cadaEuroTextTertiary.opacity(0.1)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!isNextButtonEnabled)
        .accessibilityLabel("Próximo período")
        .accessibilityHint(isNextButtonEnabled ? "Navegar para o próximo mês" : "Não é possível navegar para o futuro")
    }
    
    // MARK: - Computed Properties
    
    private var formattedPeriod: String {
        PeriodPicker.formatPeriod(month: currentMonth, year: currentYear)
    }
    
    private var isNextButtonEnabled: Bool {
        // Não permitir navegar para o futuro
        let calendar = Calendar.current
        let now = Date()
        let currentDate = DateComponents(year: currentYear, month: currentMonth, day: 1)
        
        guard let periodDate = calendar.date(from: currentDate),
              let nextMonth = calendar.date(byAdding: .month, value: 1, to: periodDate) else {
            return false
        }
        
        return nextMonth <= now
    }
}

// MARK: - Previews

#Preview("Stats Navigation Bar") {
    VStack(spacing: 24) {
        // Período atual
        StatsNavigationBar(
            currentMonth: Calendar.current.component(.month, from: Date()),
            currentYear: Calendar.current.component(.year, from: Date()),
            onPreviousMonth: { print("Previous month") },
            onNextMonth: { print("Next month") },
            onShowPicker: { print("Show picker") }
        )
        
        // Período passado
        StatsNavigationBar(
            currentMonth: 10,
            currentYear: 2024,
            onPreviousMonth: { print("Previous month") },
            onNextMonth: { print("Next month") },
            onShowPicker: { print("Show picker") }
        )
        
        // Período mais antigo
        StatsNavigationBar(
            currentMonth: 6,
            currentYear: 2023,
            onPreviousMonth: { print("Previous month") },
            onNextMonth: { print("Next month") },
            onShowPicker: { print("Show picker") }
        )
    }
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("Stats Navigation Bar - Dark") {
    StatsNavigationBar(
        currentMonth: 11,
        currentYear: 2024,
        onPreviousMonth: { print("Previous month") },
        onNextMonth: { print("Next month") },
        onShowPicker: { print("Show picker") }
    )
    .padding()
    .background(ThemeProvider.darkPreview.theme.colors.cadaEuroBackground)
    .themeProvider(.darkPreview)
    .preferredColorScheme(.dark)
}

#Preview("Stats Navigation Bar in Card") {
    VStack(spacing: 16) {
        Text("Navegar por Período")
            .font(.headline)
        
        StatsNavigationBar(
            currentMonth: 12,
            currentYear: 2024,
            onPreviousMonth: { print("Previous month") },
            onNextMonth: { print("Next month") },
            onShowPicker: { print("Show picker") }
        )
    }
    .padding()
    .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(ThemeProvider.preview.theme.colors.cadaEuroComponentBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ThemeProvider.preview.theme.colors.cadaEuroSeparator, lineWidth: 0.5)
            )
    )
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}
