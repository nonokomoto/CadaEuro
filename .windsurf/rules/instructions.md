---
trigger: always_on
---

# Instruções Simplificadas para Desenvolvimento CadaEuro

## Regras Fundamentais

1. **Idioma**: Utilizar sempre Português de Portugal (não Português do Brasil).

2. **Tecnologias Core**:
   - **iOS 17+** como plataforma mínima
   - **SwiftUI** exclusivamente (nunca UIKit)
   - **SwiftData** para persistência
   - **Environment API moderno** com `@Environment(\.themeProvider)`
   - 

CONFIRMAR SEMPRE COM ARQUIVO THEME ANTES DE USAR QUALQUER COISA REFERENTE AO DESIGN

3. **Arquitetura Modular**: Respeitar rigorosamente a separação em Swift Packages:
```
CadaEuro/
├── CadaEuroUI/              # Vistas SwiftUI, temas, design system
├── CadaEuroDomain/          # Casos de uso (AddItem, ComputeTotal)
├── CadaEuroData/            # Repositórios (ItemRepository, SettingsRepository)
├── CadaEuroOCR/             # Wrapper VisionKit, pré-processamento
├── CadaEuroSpeech/          # Captura/parse de voz
├── CadaEuroLLM/             # Abstração OpenAI/Gemini com retry, caching
├── CadaEuroKit/             # Utilitários, telemetry, extensões
└── App/                     # Ponto de entrada da aplicação
```

## Design System

### ThemeProvider



### Tokens de Design

#### Cores
```swift
// Backgrounds
themeProvider.theme.colors.cadaEuroBackground       // Fundo principal
themeProvider.theme.colors.cadaEuroComponentBackground  // Cards/componentes

// Textos
themeProvider.theme.colors.cadaEuroTextPrimary      // Texto principal
themeProvider.theme.colors.cadaEuroTextSecondary    // Texto secundário
themeProvider.theme.colors.cadaEuroTextTertiary     // Texto terciário

// Ação
themeProvider.theme.colors.cadaEuroAccent           // Azul #007AFF
themeProvider.theme.colors.cadaEuroTotalPrice       // Preço total (com glow no dark)
```

#### Tipografia
```swift
themeProvider.theme.typography.totalPrice     // 48pt Medium (preço total)
themeProvider.theme.typography.titleLarge     // 28pt Bold (títulos)
themeProvider.theme.typography.titleMedium    // 20pt Medium (subtítulos)
themeProvider.theme.typography.bodyLarge      // 18pt Medium (corpo principal)
```

#### Espaçamento
```swift
themeProvider.theme.spacing.xs                // 8px (espaçamento mínimo)
themeProvider.theme.spacing.sm                // 16px (espaçamento pequeno)
themeProvider.theme.spacing.lg                // 20px (margins globais)
themeProvider.theme.spacing.xl                // 24px (padding horizontal cards)
themeProvider.theme.spacing.xxl               // 40px (espaçamento seções)
themeProvider.theme.spacing.xxxl              // 80px (espaçamento grande)
```



## Objetivos Técnicos

- **Performance**: Tempo de arranque cold < 1s; reconhecimento OCR < 300ms por item
- **Acessibilidade**: Conformidade WCAG 2.1 AA, Dynamic Type até XXL
- **Fiabilidade**: Crash-free sessions ≥ 99%

## Referências

Para detalhes completos, consultar:
- Documento Técnico (Documento_Tecnico_CadaEuro_v1.md)
- Design System (DESIGN_SYSTEM.md)