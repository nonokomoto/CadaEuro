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
| UI & Estado         | **SwiftUI + Combine**                | Navegação stack-based, animações Swift Concurrency        |
| OCR                 | **VisionKit TextRecognizer**         | On-device; pré-processamento CIImage (binarização)        |
| Voz                 | **SpeechRecognizer**                 | Locale pt-PT; transcrição streaming                       |
| LLM                 | **GPT-4.1 mini / Gemini 2 Flash**    | Normalização de texto; fallback nano                      |
| Persistência        | **SwiftData**                        | Modelos versionados; migração leve                        |
| Sync                | **CloudKit**                         | Database privada; record zones por utilizador             |
| Analytics & Crashes | **Mixpanel, Firebase Crashlytics**   | Eventos funil e erros                                     |
| CI/CD               | **GitHub Actions + Fastlane**        | Automatizar build, testes, distribuição TestFlight        |
| Monitorização       | **Xcode Cloud Metrics**              | Tempo build, regressão performance                        |

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

---

## 4. Fluxos de Dados

### 4.1 OCR

```mermaid
sequenceDiagram
User → UI: Captura imagem
UI → OCRService: detectText()
OCRService → LLMService: normalize(rawText)
LLMService → Domain: send(Item(price))
Domain → DataStore: save(Item)
UI ← Domain: update total
```

### 4.2 Voz

Idêntico, substituindo VisionKit por SpeechRecognizer.

---

## 5. Persistência & Sincronização

- **Modelos SwiftData**: Item, ShoppingList, UserSettings
- **Migrations**: Automáticas; migrar campos adicionados sem downtime
- **CloudKit**: Sincronização automática; conflitos resolvidos via última edição
- **Data Protection**: NSFileProtectionCompleteUntilFirstUserAuthentication

---

## 6. Gestão de Estado

Implementar State Container com @Observable (Swift 5.9) + ViewModel por ecrã. Reducers isolados facilitam testes.

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

---

## 13. Performance & Otimização

- Evitar @State excessivo; usar @StateObject
- Reutilizar instâncias VisionKit
- Cache de respostas LLM (NSCache 5 min.)

---

## 14. Estrutura de Diretórios (resumo)

```plaintext
CadaEuro/
 ├─ App/
 ├─ Features/
 │   ├─ OCR/
 │   ├─ Voice/
 │   └─ ManualInput/
 ├─ Core/
 ├─ Resources/
 ├─ Tests/
 └─ Scripts/
```

---

## 15. Convenções de Código

- **SwiftLint**: adotar regras raywenderlich + custom
- Sufixos ViewModel, Repository, Service
- Comentários Markdown quando necessário contexto (não obviedade)

---

## 16. Riscos Técnicos & Mitigações

| Risco                                   | Impacto | Plano                                                         |
|-----------------------------------------|---------|---------------------------------------------------------------|
| Aumento custos LLM                      | Alto    | Cache, batch requests, renegociação anual                     |
| Limites VisionKit em recibos mal impressos | Médio  | Pré-processamento imagem, confidence score fallback manual    |
| Conflitos CloudKit                      | Médio   | Estratégia last-writer-wins, diff visual                      |

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

- Build compila sem erros/warnings nível crítico
- Testes automatizados passam (coverage ≥ 80 %)
- Novo código revisto (1 revisor), lint ok
- QA confirma requisitos HIG & A11y

---

## 19. Referências

- Apple Documentation: VisionKit, SpeechRecognizer, SwiftData
- Human Interface Guidelines (2025)
- Google Generative AI Swift SDK
- OpenAI swift SDK

---

**Última actualização:** 22 Maio 2025
