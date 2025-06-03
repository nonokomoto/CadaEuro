import SwiftUI

/// Card para exibir uma métrica estatística individual
public struct StatsMetricsCard: View {
    @Environment(\.themeProvider) private var themeProvider
    
    // MARK: - Properties
    private let title: String
    private let value: String
    private let icon: String
    private let iconColor: Color
    
    // MARK: - State
    @State private var isPressed = false
    
    public init(
        title: String,
        value: String,
        icon: String,
        iconColor: Color = .blue
    ) {
        self.title = title
        self.value = value
        self.icon = icon
        self.iconColor = iconColor
    }
    
    public var body: some View {
        VStack(spacing: themeProvider.theme.spacing.md) {
            // Ícone principal
            iconSection
            
            // Valor em destaque
            valueSection
            
            // Título/descrição
            titleSection
        }
        .frame(maxWidth: .infinity)
        .padding(themeProvider.theme.spacing.lg)
        .background(cardBackground)
        .cornerRadius(themeProvider.theme.border.cardRadius)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture { }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(themeProvider.theme.animation.quick) {
                isPressed = pressing
            }
        }, perform: { })
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var iconSection: some View {
        ZStack {
            // Background circular
            Circle()
                .fill(iconColor.opacity(0.15))
                .frame(width: 44, height: 44)
            
            // Ícone
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(iconColor)
        }
    }
    
    @ViewBuilder
    private var valueSection: some View {
        Text(value)
            .font(themeProvider.theme.typography.titleLarge)
            .fontWeight(.bold)
            .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }
    
    @ViewBuilder
    private var titleSection: some View {
        Text(title)
            .font(themeProvider.theme.typography.bodySmall)
            .foregroundColor(themeProvider.theme.colors.cadaEuroTextSecondary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
    }
    
    // MARK: - Computed Properties
    
    private var cardBackground: Color {
        themeProvider.theme.colors.cadaEuroComponentBackground
    }
}

// MARK: - Previews

#Preview("Stats Metrics Cards") {
    VStack(spacing: 16) {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            StatsMetricsCard(
                title: "Total Gasto",
                value: "€234,89",
                icon: "eurosign.circle.fill",
                iconColor: .blue
            )
            
            StatsMetricsCard(
                title: "Listas Criadas",
                value: "8",
                icon: "list.bullet.circle.fill",
                iconColor: .green
            )
            
            StatsMetricsCard(
                title: "Média por Lista",
                value: "€29,36",
                icon: "chart.bar.fill",
                iconColor: .orange
            )
            
            StatsMetricsCard(
                title: "Total de Itens",
                value: "67",
                icon: "cart.fill",
                iconColor: .purple
            )
        }
    }
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}

#Preview("Stats Metrics Card - Dark") {
    LazyVGrid(columns: [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ], spacing: 16) {
        StatsMetricsCard(
            title: "Total Gasto",
            value: "€456,78",
            icon: "eurosign.circle.fill",
            iconColor: .blue
        )
        
        StatsMetricsCard(
            title: "Listas Criadas",
            value: "12",
            icon: "list.bullet.circle.fill",
            iconColor: .green
        )
    }
    .padding()
    .background(ThemeProvider.darkPreview.theme.colors.cadaEuroBackground)
    .themeProvider(.darkPreview)
    .preferredColorScheme(.dark)
}

#Preview("Single Metrics Card") {
    StatsMetricsCard(
        title: "Média por Lista",
        value: "€45,67",
        icon: "chart.bar.fill",
        iconColor: .orange
    )
    .padding()
    .background(ThemeProvider.preview.theme.colors.cadaEuroBackground)
    .themeProvider(.preview)
}
