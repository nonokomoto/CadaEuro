# Documento Técnico – CadaEuro (v1.0)

## 1. Visão Geral

A aplicação **CadaEuro** (iOS 17+) ajuda consumidores a controlar em tempo real o total das compras de supermercado através de OCR, voz e entrada manual. Este documento define a arquitetura, padrões e processos necessários para desenvolver e manter o produto alinhado ao roadmap e KPIs estabelecidos.

**Objetivos Técnicos:**
- **Performance:** Tempo de arranque *cold* < 1 s; reconhecimento OCR < 300 ms por item.
- **Fiabilidade:** Crash-free sessions ≥ 99 %.
- **Escalabilidade:** Modularização para futura porta Android e novos inputs (ex.: códigos de barras).
- **Usabilidade & Acessibilidade:** Conformidade HIG, WCAG 2.1 AA, Dynamic Type.

---

## 2. Stack Tecnológico

| Camada              | Tecnologia                           | Notas                                                     |
|---------------------|--------------------------------------|-----------------------------------------------------------|
| **UI & Estado**     | **SwiftUI EXCLUSIVO**                | **🚫 PROIBIDO UIKit** - Navegação stack-based, animações Swift 6 |
| Concorrência        | **Swift 6 Strict Concurrency**      | @Observable, @MainActor, Sendable compliance              |
| OCR                 | **VisionKit TextRecognizer**         | On-device; pré-processamento CIImage (binarização)        |
| Voz                 | **SpeechRecognizer**                 | Locale pt-PT; transcrição streaming                       |
| LLM                 | **GPT-4.1 mini / Gemini 2 Flash**    | Normalização de texto; fallback nano                      |
| Persistência        | **SwiftData**                        | Modelos versionados; migração leve                        |
| Sync                | **CloudKit**                         | Database privada; record zones por utilizador             |
| Analytics & Crashes | **Mixpanel, Firebase Crashlytics**   | Eventos funil e erros                                     |
| CI/CD               | **GitHub Actions + Fastlane**        | Automatizar build, testes, distribuição TestFlight        |
| Monitorização       | **Xcode Cloud Metrics**              | Tempo build, regressão performance                        |

---

## 2.1 Política SwiftUI-Only (PRIORIDADE MÁXIMA)

### 🚫 Restrições Absolutas
- **PROIBIDO uso de UIKit** - Nenhuma importação `import UIKit`
- **PROIBIDO UIViewController** - Apenas Views SwiftUI nativas
- **PROIBIDO UIView wrapping** - Sem `UIViewRepresentable`
- **PROIBIDO UIColor** - Apenas `SwiftUI.Color`
- **PROIBIDO Auto Layout** - Apenas layout SwiftUI nativo

### ✅ Alternativas SwiftUI Obrigatórias

| UIKit (PROIBIDO) | SwiftUI (OBRIGATÓRIO) | Uso |
|------------------|----------------------|-----|
| `UIColor.systemBackground` | `Color(.systemBackground)` | Cores do sistema |
| `UIViewController` | `@StateObject ViewModel` | Gestão de estado |
| `UITableView` | `List` ou `LazyVStack` | Listas de dados |
| `UINavigationController` | `NavigationStack` | Navegação |
| `UIAlertController` | `.alert()` modifier | Alertas |
| `UIActivityViewController` | `ShareLink` | Partilha |
| `UIImagePickerController` | `PhotosPicker` | Seleção de fotos |

### 🎯 Justificação Técnica
1. **Consistência de Design**: SwiftUI garante HIG compliance automática
2. **Performance**: Eliminação de overhead UIKit ↔ SwiftUI
3. **Manutenibilidade**: Código unificado sem bridging
4. **Futuro-prova**: Preparação para visionOS e multiplataforma
5. **Acessibilidade**: Suporte nativo superior no SwiftUI

---

## 3. Arquitetura de Software

```plaintext
┌────────────┐        ┌──────────────┐
│ Presentation│◄──────│   Domain     │
└────────────┘   ◄───►└──────────────┘
                 ◄───►┌──────────────┐
                 │    │    Data      │
                 ▼    └──────────────┘
                 Core (Utils, Logging)
```

### 3.1 Principais Módulos (Swift Packages)

1. **CadaEuroUI** – Vistas SwiftUI, temas, design system  
2. **CadaEuroDomain** – Casos de uso (AddItem, ComputeTotal)  
3. **CadaEuroData** – Repositórios (ItemRepository, SettingsRepository)  
4. **CadaEuroOCR** – Wrapper VisionKit, pós-processamento  
5. **CadaEuroSpeech** – Captura/parse de voz  
6. **CadaEuroLLM** – Abstração OpenAI/Gemini com retry, caching  
7. **CadaEuroKit** – Utilitários, telemetry, extensões

### 3.2 Swift 6 Concurrency & Safety

#### Estratégia de Isolamento
```swift
// ThemeProvider - MainActor isolado para UI
@Observable
@MainActor
public final class ThemeProvider: Sendable {
    public private(set) var theme: AppTheme
}

// ✅ SwiftUI-Only - Sem UIKit
// ❌ PROIBIDO: import UIKit
// ❌ PROIBIDO: UIColor.systemBackground
// ✅ CORRETO: Color(.systemBackground)

// Modelos de dados - Sendable para thread safety
public struct ShoppingItem: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let price: Double
    // ... campos imutáveis
}

// Enums - Sendable para uso em contextos concorrentes
public enum CaptureMethod: String, CaseIterable, Sendable {
    case scanner, voice, manual
}
```

#### Padrões de Concorrência
- **@MainActor**: UI components, ThemeProvider, ViewModels
- **Sendable**: Modelos de dados, enums, structs imutáveis
- **Environment**: Injeção única com propagação automática
- **Computed Properties**: Métodos @MainActor para evitar isolation errors

#### Resolução de Erros Comuns
```swift
// ❌ Erro: Main actor-isolated property em contexto nonisolated
var textColor: (ThemeProvider) -> Color { ... }

// ✅ Solução: Método com MainActor isolation
@MainActor
func textColor(for themeProvider: ThemeProvider) -> Color { ... }
```

---

## 4. Design System & Theme Management

### 4.1 ThemeProvider Architecture (SwiftUI-Only)

#### Injeção Única, Consumo Global
```swift
// App.swift - Injeção no ponto de entrada
ContentView()
    .cadaEuroTheme() // ✅ Uma vez no topo

// Qualquer View - Consumo automático
@Environment(\.themeProvider) private var themeProvider
```

#### Tokens Centralizados
- **ColorTokens**: Cores adaptativas light/dark
- **TypographyTokens**: Fontes escaláveis com Dynamic Type
- **SpacingTokens**: Grid 8px com aliases semânticos
- **BorderTokens**: Raios e larguras consistentes
- **AnimationTokens**: Durações e curvas padronizadas

#### Environment Safety
```swift
// Resolução de defaultValue sem MainActor conflicts
private struct ThemeProviderKey: EnvironmentKey {
    static let defaultValue: ThemeProvider? = nil
}

public extension EnvironmentValues {
    var themeProvider: ThemeProvider {
        @MainActor
        get { 
            self[ThemeProviderKey.self] ?? ThemeProvider()
        }
        set { self[ThemeProviderKey.self] = newValue }
    }
}
```

### 4.2 Componentes Reutilizáveis

#### Hierarquia de Componentes
```
Components/
├── ActionButton       # Botões primários/secundários/destrutivos
├── CaptureButton      # Botões específicos de captura (Scanner/Voz/Manual)
│   └── onLongPress    # ✅ NOVO: Callback para VoiceRecorderView
├── VoiceRecorderView  # ✅ COMPLETO: Interface inline de gravação
│   ├── Inline expansion (sem modal)
│   ├── Long press integration
│   ├── Audio visualizer
│   ├── State management (idle→recording→transcribed)
│   └── SwiftUI-Only compliance
├── ItemCard           # Cards de produtos com swipe-to-delete
├── EmptyStateView     # Estados vazios com CTAs contextuais
├── TotalDisplayView   # Display premium do total
└── ManualInputForm    # Formulário de entrada manual
```

#### ✅ Integração VoiceRecorderView (NOVO)
```swift
// ShoppingListView integration pattern
VStack {
    // Total display
    TotalDisplay(amount: viewModel.total)
    
    // Voice recording interface
    VoiceRecorderView { transcription in
        viewModel.addItem(from: transcription)
    } onError: { error in
        viewModel.showError(error)
    }
    
    // Other capture methods
    HStack {
        CaptureButton(method: .scanner) { /* scanner */ }
        CaptureButton(method: .manual) { /* manual */ }
    }
}
```

---

## 5. Persistência & Sincronização

- **Modelos SwiftData**: Item, ShoppingList, UserSettings
- **Migrations**: Automáticas; migrar campos adicionados sem downtime
- **CloudKit**: Sincronização automática; conflitos resolvidos via última edição
- **Data Protection**: NSFileProtectionCompleteUntilFirstUserAuthentication

---


## 7. Dependências & Gestão de Pacotes

```swift
.package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.2"),
.package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.7.0"),
.package(url: "https://github.com/OpenAI/openai-swift", from: "1.0.0"),
.package(url: "https://github.com/google/generative-ai-swift", from: "0.2.0")
```

---

## 8. Segurança & Privacidade

- Armazenar apiKey LLM no **Keychain** com kSecAttrAccessibleAfterFirstUnlock
- Minimizar dados pessoais; sem localização
- **App Privacy**: NSUserTrackingUsageDescription não requerido
- **TLS 1.3** obrigatório para chamadas de rede

---

## 9. Testes

| Tipo      | Ferramenta             | Metas                                  |
|-----------|------------------------|----------------------------------------|
| Unitário  | XCTest, Quick/Nimble   | Cobertura ≥ 80 %, TDD casos críticos   |
| Snapshot  | iOSSnapshotTestCase    | Regressão UI                           |
| UI        | XCUITest + Fastlane    | Fluxos principais, Happy Path e erros  |
| Integração| MockServer (Swift)     | Repositórios ↔ LLM                     |

---

## 10. CI/CD

1. **Lint & Tests** – swiftlint, xcodebuild test em GitHub Actions
2. **Build** – Assinatura automática xcode-project run
3. **Distribuição** – fastlane pilot upload → TestFlight ao Friday Release Train
4. **Static Analysis** – swift-format, SonarCloud opcional

---

## 11. Monitorização & Analytics

- **Crashlytics**: alertas Slack se crash-free < 99 %
- **Mixpanel**: funil "Add Item → Checkout"
- **OSLog**: Unified logging subsystem = "app.cadaeuro"

---

## 12. Acessibilidade

- AccessibilityLabel para todos os elementos interativos
- Suporte VoiceOver (rotulagem ordenada)
- Dynamic Type escalonável até XXL
- Contraste mínimo 4.5:1

### Conformidade Sendable para Previews
```swift
// Dados de preview thread-safe
extension ShoppingItem {
    static let sampleItems: [ShoppingItem] = [
        ShoppingItem(name: "Leite", price: 1.29, captureMethod: .scanner),
        // ... outros itens
    ]
}

// Enums de estado Sendable
public enum ItemCardState: Sendable {
    case normal, editing, deleting, selected
}
```

---

## 13. Performance & Otimização

- Evitar @State excessivo; usar @StateObject
- Reutilizar instâncias VisionKit
- Cache de respostas LLM (NSCache 5 min.)
- **MainActor Isolation**: UI updates garantidamente na main thread
- **Sendable Compliance**: Thread safety sem overhead de locks
- **Environment Propagation**: Evita prop drilling manual
- **Computed Properties**: Lazy evaluation com caching automático

---

## 15. Convenções de Código

- **SwiftLint**: adotar regras raywenderlich + custom
- Sufixos ViewModel, Repository, Service
- Comentários Markdown quando necessário contexto (não obviedade)

### Swift 6 + SwiftUI-Only Guidelines

#### Imports Permitidos
```swift
// ✅ PERMITIDOS
import SwiftUI
import SwiftData
import VisionKit
import Speech
import CloudKit
import Combine

// 🚫 ABSOLUTAMENTE PROIBIDOS
// import UIKit          ❌
// import Foundation     ⚠️ (apenas se necessário para tipos específicos)
```

#### Padrões de Código SwiftUI
```swift
// ✅ CORRETO - ViewModifier SwiftUI
struct CadaEuroButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// ❌ PROIBIDO - Qualquer UIKit
// class CustomViewController: UIViewController { }
```

#### Navegação SwiftUI Nativa
```swift
// ✅ CORRETO - NavigationStack
NavigationStack {
    ShoppingListView()
        .navigationDestination(for: ShoppingItem.self) { item in
            ItemDetailView(item: item)
        }
}

// ❌ PROIBIDO - UINavigationController
// let navController = UINavigationController()
```

#### Gestão de Estado SwiftUI
```swift
// ✅ CORRETO - @Observable + @StateObject
@Observable
class ShoppingListViewModel {
    var items: [ShoppingItem] = []
    var total: Double = 0.0
}

// ❌ PROIBIDO - UIViewController patterns
// class ShoppingListViewController: UIViewController { }
```

---

## 16. Riscos Técnicos & Mitigações

| Risco                                   | Impacto | Plano                                                         |
|-----------------------------------------|---------|---------------------------------------------------------------|
| **Tentação de usar UIKit**              | **CRÍTICO** | **Code reviews obrigatórios, linting rules, formação equipa** |
| Limitações SwiftUI específicas         | Médio   | Workarounds nativos, aguardar updates iOS                    |
| Performance em listas grandes           | Médio   | LazyVStack, paginação, otimização de rendering               |
| Aumento custos LLM                      | Alto    | Cache, batch requests, renegociação anual                     |
| Limites VisionKit em recibos mal impressos | Médio  | Pré-processamento imagem, confidence score fallback manual    |
| Conflitos CloudKit                      | Médio   | Estratégia last-writer-wins, diff visual                      |
| MainActor isolation conflicts          | Alto    | Padrões estabelecidos, métodos com @MainActor explicit       |
| Sendable compliance breaking changes   | Médio   | Progressive adoption, wrapper types para legacy code         |

---

## 17. Cronograma Técnico (alto nível)

| Sprint | Épica               | Entregável            |
|--------|---------------------|-----------------------|
| 1-2    | Infra & Setup       | SPM, CI, skeleton app |
| 3-4    | OCR                 | Captura & parsing V0  |
| 5-6    | Voz                 | Speech input V0       |
| 7-8    | Persistência & Sync | Models + CloudKit     |
| 9-10   | UX Refinements      | Lista, tema escuro    |
| 11-12  | MVP TestFlight      | Beta Q3-2025          |

---

## 18. Definição de Done

- ✅ **Build compila sem erros/warnings nível crítico**
- ✅ **ZERO imports UIKit** - Verificação automática via linting
- ✅ **SwiftUI-Only compliance** - Review obrigatório
- ✅ **Testes automatizados passam (coverage ≥ 80 %)**
- ✅ **Novo código revisto (1 revisor), lint ok**
- ✅ **QA confirma requisitos HIG & A11y**

### Checklist SwiftUI-Only
- [ ] Nenhum `import UIKit` no código
- [ ] Nenhuma classe `UIViewController`
- [ ] Nenhum `UIViewRepresentable`
- [ ] Apenas `SwiftUI.Color` (não `UIColor`)
- [ ] Layout exclusivamente SwiftUI
- [ ] Navegação via `NavigationStack`
- [ ] Modais via `.sheet()` e `.alert()`

---

## 19. Ferramentas de Enforcement

### SwiftLint Rules Customizadas
```yaml
# .swiftlint.yml
disabled_rules: []

custom_rules:
  no_uikit_import:
    name: "No UIKit Import"
    regex: "import UIKit"
    message: "🚫 PROIBIDO: Uso de UIKit não permitido"
    severity: error
    
  no_uiviewcontroller:
    name: "No UIViewController"
    regex: "UIViewController"
    message: "🚫 PROIBIDO: Use @StateObject ViewModel"
    severity: error
```

### GitHub Actions CI Check
```yaml
- name: Check SwiftUI-Only Compliance
  run: |
    if grep -r "import UIKit" . --exclude-dir=.git; then
      echo "🚫 ERROR: UIKit import found"
      exit 1
    fi
```

---

**Última actualização:** 30 Maio 2025
**Swift Version:** 6.0
**iOS Target:** 17.0+
**UI Framework:** SwiftUI EXCLUSIVO 🎯
