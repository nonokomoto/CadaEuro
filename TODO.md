# 📝 CadaEuro - Lista de Tarefas (TODO)

## 🚨 Prioridades Críticas

### 🎯 Implementação SwiftUI-Only
- [ ] **Feedback Háptico Nativo SwiftUI** - Implementar SensoryFeedback quando disponível
  ```swift
  .onChange(of: currentPage) { _, newPage in
      // ✅ SwiftUI-Only: Sem UIImpactFeedbackGenerator  
      // Feedback háptico será adicionado via SensoryFeedback quando disponível
  }
  ```
- [ ] **Verificar todas as importações** - Garantir zero `import UIKit`
- [ ] **Code Review SwiftUI-Only** - Revisar todos os componentes existentes
- [ ] **Linting Rules** - Implementar regras customizadas para bloquear UIKit

### 🔧 Componentes Fundamentais
- [x] **CaptureMethodSelector** - Finalize preview funcionando
- [x] **ItemCard** - Implementar swipe-to-delete
- [x] **ListCard** - Cards para listas guardadas
- [x] **MenuButton** - Botão ellipsis com menu contextual nativo
- [x] **PeriodPicker** - Seletor de período para estatísticas
- [x] **ScannerOverlay** - Interface de scanner OCR premium
  - [x] Estados visuais completos (idle, scanning, processing, success, error)
  - [x] Mensagens descontraídas em português PT ("Só um segundo...", "Ups...")
  - [x] Animações premium (linha de scan, cantos pulsantes)
  - [x] Frame de captura com indicadores visuais
  - [x] Simulação completa para desenvolvimento
  - [x] Feedback visual de estados (cores, overlays)
  - [x] **SwiftUI-Only Compliance** - Comentários sobre SensoryFeedback
  - [ ] **VisionKit Integration** - Substituir simulação por OCR real
  - [ ] **SensoryFeedback** - Feedback háptico nas transições
  - [ ] **Error Recovery** - Melhorar retry e fallback automático
- [x] **TotalDisplay** - Componente premium para mostrar total
  - [x] **SwiftUI-Only Compliance** - Comentários sobre SensoryFeedback
- [x] **VoiceRecorderView** - Interface de gravação estilo WhatsApp/Apple Watch ✅ COMPLETO
  - [x] Interface estilo WhatsApp com long press para gravar
  - [x] ~~Modal de gravação estilo Apple Watch~~ **→ INLINE EXPANSION**
  - [x] Audio visualizer com barras animadas
  - [x] Estados completos (idle, recording, recorded, processing, transcribed, error)
  - [x] Ações pós-gravação (delete, send)
  - [x] **Integração com CaptureButton** - Long press automático
  - [x] **Interface Inline** - Expansão horizontal sem modal
  - [x] Swift 6 concurrency compliance (MainActor, Sendable)
  - [x] Equatable conformance para enum com associated values
  - [x] SpeechRecognizer permission handling
  - [x] Mock transcription para desenvolvimento
  - [x] Timer management com cleanup automático
  - [x] SwiftUI-Only (sem UIKit dependencies)
  - [x] **SwiftUI-Only Compliance** - Comentários sobre SensoryFeedback
  - [x] Português PT localization
  - [x] Acessibilidade completa (labels, hints)
  - [x] **Preview Fix** - Proteção contra TCC crashes
  - [ ] **Speech Recognition Real** - Substituir mock por SFSpeechRecognizer
  - [ ] **Audio Recording** - Implementar gravação real de áudio
  - [ ] **LLM Integration** - Processamento de transcrição via GPT/Gemini
  - [ ] **Error Recovery** - Melhorar handling de falhas
- [x] **ManualInputForm** - Formulário de entrada manual ✅ COMPLETO
  - [x] Interface minimalista (apenas nome + preço)
  - [x] Validação em tempo real com feedback visual
  - [x] Teclado numérico para preços (.keyboardType(.decimalPad))
  - [x] Foco automático e navegação entre campos
  - [x] Formatação portuguesa (vírgula separador decimal)
  - [x] Validações específicas (100 chars nome, €9999.99 max preço)
  - [x] Botão habilitado apenas com dados válidos
  - [x] Design minimalista Apple Store style
  - [x] SwiftUI-Only compliance (sem UIKit)
  - [x] Sendable/thread safety (ProductData, ValidationError)
  - [x] Acessibilidade completa (labels, focus management)
  - [x] Reset automático após adicionar produto
  - [x] Callback pattern para integração com ShoppingListView
  - [ ] **Error Recovery** - Melhorar mensagens de erro contextual
  - [ ] **Smart Suggestions** - Autocomplete baseado em histórico
- [x] **ConfirmationDialog** - Diálogo de confirmação premium ✅ COMPLETO
  - [x] Interface modal para confirmação de produtos OCR
  - [x] Campos editáveis (nome + preço) iguais ao ManualInputForm
  - [x] Botões de confirmação e cancelamento
  - [x] Validação em tempo real
  - [x] Design system integrado com ActionButton
  - [x] Estados específicos (delete, reset, clearData, overwrite)
  - [x] SwiftUI-Only compliance
  - [x] Sendable/thread safety
  - [x] Extension helper .confirmationDialog() modifier
  - [ ] **OCR Integration** - Integração com ScannerOverlay
  - [ ] **LLM Product Confirmation** - Modal pós-processamento
- [x] **ProductConfirmationDialog** - Diálogo específico para confirmação OCR ✅ COMPLETO
  - [x] Interface modal para confirmação de produtos OCR
  - [x] Campos editáveis (nome + preço) reutilizando ManualInputForm
  - [x] Validação em tempo real idêntica
  - [x] ActionButton integrado para consistência
  - [x] Extension helper .productConfirmationDialog() modifier
  - [x] SwiftUI-Only compliance
  - [x] Sendable/thread safety
  - [x] Inicialização automática com dados OCR
  - [x] Focus management e navegação entre campos
  - [x] Formatação portuguesa (vírgula decimal)
  - [ ] **OCR Integration** - Integração com ScannerOverlay
  - [ ] **LLM Product Confirmation** - Modal pós-processamento

---

## 🏗️ Arquitetura & Infraestrutura

### 📦 Swift Packages
- [ ] **CadaEuroDomain** - Casos de uso e entidades
- [ ] **CadaEuroData** - Repositórios e SwiftData models
- [ ] **CadaEuroOCR** - Wrapper VisionKit
- [ ] **CadaEuroSpeech** - Reconhecimento de voz
- [ ] **CadaEuroLLM** - Integração OpenAI/Gemini

### 🗃️ Persistência
- [ ] **SwiftData Models** - ShoppingItem, ShoppingList, UserSettings
- [ ] **CloudKit Integration** - Sincronização automática
- [ ] **Data Migration** - Estratégia de versionamento
- [ ] **Offline Support** - Cache local com sync posterior

---

## 🎨 UI/UX Premium

### 🌟 Microinterações
- [ ] **SensoryFeedback Implementation** - Quando disponível no SwiftUI
  ```swift
  // TODO: Substituir comentários por implementação real nos componentes:
  // ✅ SwiftUI-Only: Sem UIImpactFeedbackGenerator
  // Feedback háptico será adicionado via SensoryFeedback quando disponível
  
  .sensoryFeedback(.impact(.light), trigger: pageChange)
  
  // MenuButton feedback específico:
  .sensoryFeedback(.selection, trigger: menuAction)
  
  // VoiceRecorderView feedback específico:
  .sensoryFeedback(.impact(.medium), trigger: recordingStart)
  
  // ScannerOverlay feedback específico:
  .sensoryFeedback(.success, trigger: scanSuccess)
  ```
- [ ] **Spring Animations** - Refinamento de curvas e timing
- [ ] **Glow Effects** - Dark mode premium enhancements
- [ ] **Loading States** - Indicadores elegantes durante processamento

### ♿ Acessibilidade
- [ ] **VoiceOver Testing** - Testar todos os fluxos
- [ ] **Dynamic Type** - Verificar todos os tamanhos de fonte
- [ ] **Contrast Validation** - Garantir 4.5:1 mínimo
- [ ] **Reduced Motion** - Alternativas para animações

### 🎭 Estados Visuais
- [ ] **Empty States** - Melhorar EmptyStateView com ações contextuais
- [ ] **Error States** - Estados de erro elegantes com recovery
- [ ] **Loading States** - Skeletons e shimmers
- [ ] **Success States** - Confirmações visuais satisfatórias

---

## 🔍 Funcionalidades Core

### 📷 Scanner OCR
- [ ] **VisionKit Integration** - Wrapper SwiftUI nativo
  - [x] **ScannerOverlay UI** - Interface completa implementada
  - [ ] **TextRecognizer Integration** - Substituir simulação
  - [ ] **Camera Permissions** - Gestão de autorizações
- [ ] **Image Preprocessing** - Binarização via CIImage
- [ ] **Performance Optimization** - < 300ms por item
- [ ] **Error Handling** - Fallback para entrada manual
- [ ] **Mensagens de Feedback** - Texto descontraído PT já implementado

### 🎤 Reconhecimento de Voz
- [ ] **SpeechRecognizer Setup** - Locale pt-PT
- [ ] **Streaming Transcription** - Feedback em tempo real
- [ ] **Privacy Handling** - Permissões e on-device processing
- [ ] **Mock Data** - Para simulador development

### 🤖 LLM Integration
- [ ] **OpenAI Client** - GPT-4.1 mini integration
- [ ] **Gemini Fallback** - Gemini 2 Flash como backup
- [ ] **Response Caching** - NSCache 5 min duration
- [ ] **Error Handling** - Retry logic e fallbacks

### ⌨️ Entrada Manual
- [x] **ManualInputForm Component** - Implementado e funcionando
- [x] **Validation Logic** - Nome e preço obrigatórios ✅
- [x] **Real-time Validation** - Feedback imediato ✅
- [x] **Keyboard Optimization** - Teclado numérico para preços ✅
- [x] **Form State Management** - Enable/disable submit button ✅
- [ ] **ShoppingListView Integration** - Conectar ManualInputForm
- [ ] **Smart Input Enhancement** - Sugestões baseadas em histórico
- [ ] **Barcode Fallback** - Entrada manual após falha de scanner

---

## 📊 Ecrãs Principais

### 🏠 ShoppingListView
- [ ] **Layout Principal** - Total + Lista + Captura buttons
- [x] **VoiceRecorderView Integration** - Substituir CaptureButton por VoiceRecorderView
  ```swift
  // TODO: No ShoppingListView
  VoiceRecorderView { transcription in
      addItemFromTranscription(transcription)
  } onError: { error in
      showError(error)
  }
  ```
- [ ] **Gesture Navigation** - Swipe entre modos de captura
- [ ] **Long Press Menu** - Context menu no total
- [ ] **Pull to Refresh** - Sync manual com CloudKit
- [ ] **MenuButton Integration** - Adicionar MenuButton na NavigationBar
  ```swift
  .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
          MenuButton { action in
              handleMenuAction(action)
          }
      }
  }
  ```

### 📋 SavedListsView
- [ ] **SwiftData Integration** - Query e display de listas
- [ ] **Edit Mode** - Rename e delete listas
- [ ] **Search Functionality** - Filtros por data/nome
- [ ] **Export Feature** - Share listas via ShareLink

### 📈 StatsView
- [ ] **Period Navigation** - Swipe entre meses/anos
- [ ] **Metrics Calculation** - Total, média, contagem
- [ ] **Chart Integration** - Swift Charts para visualizações
- [ ] **Data Filtering** - Por período e categoria
- [ ] **PeriodPicker Integration** - Modal quando atinge limites
  ```swift
  .sheet(isPresented: $showingPeriodPicker) {
      PeriodPicker(
          selectedMonth: $currentMonth,
          selectedYear: $currentYear,
          isPresented: $showingPeriodPicker
      ) { month, year in
          updatePeriod(month: month, year: year)
      }
  }
  ```

### ⚙️ SettingsView
- [ ] **Account Management** - Plano PRO, restore purchases
- [ ] **Data Management** - Export/import, backup
- [ ] **Appearance Settings** - Text size, currency
- [ ] **Accessibility Options** - Contrast, motion, voice

---

## 🧪 Testes & Qualidade

### 🔬 Test Coverage
- [ ] **Unit Tests** - ViewModels, UseCases, Repositories
- [ ] **Integration Tests** - OCR, Speech, LLM workflows
- [ ] **UI Tests** - Critical user flows
- [ ] **Snapshot Tests** - Visual regression prevention

### 📏 Performance
- [ ] **Launch Time** - Cold start < 1s target
- [ ] **Memory Usage** - Profile com Instruments
- [ ] **Battery Impact** - Otimizar OCR e LLM calls
- [ ] **Network Efficiency** - Minimizar CloudKit sync

### 🛡️ Security
- [ ] **API Key Storage** - Keychain implementation
- [ ] **Data Protection** - FileProtection until first unlock
- [ ] **Privacy Audit** - Minimizar dados pessoais
- [ ] **TLS 1.3** - Enforce para network calls

---

## 🚀 DevOps & CI/CD

### 🔄 Automation
- [ ] **GitHub Actions** - Lint, test, build pipeline
- [ ] **Fastlane Setup** - Automated TestFlight distribution
- [ ] **SwiftLint Config** - Custom rules para SwiftUI-Only
- [ ] **Code Coverage** - Automated reporting

### 📊 Monitoring
- [ ] **Crashlytics** - Firebase crash reporting
- [ ] **Analytics** - Mixpanel event tracking
- [ ] **Performance** - Xcode Cloud metrics
- [ ] **User Feedback** - In-app feedback system

---

## 🎯 Melhorias Futuras

### 🔮 Funcionalidades Avançadas
- [ ] **Barcode Scanning** - Extensão do OCR atual
- [ ] **Receipt Photo** - Scan completo de recibos
- [ ] **Smart Categories** - Auto-categorização via LLM
- [ ] **Shopping Lists Sharing** - CloudKit sharing

### 🌍 Localização
- [ ] **Multi-language** - EN, FR além de PT
- [ ] **Currency Support** - USD, GBP além de EUR
- [ ] **Regional Formats** - Números e datas localizadas
- [ ] **Voice Localization** - Speech recognition multilingue

### 📱 Platform Expansion
- [ ] **iPad Optimization** - Layout adaptativo
- [ ] **macOS Catalyst** - Preparação para desktop
- [ ] **visionOS** - Preparação para Vision Pro
- [ ] **Watch Companion** - Quick add via Apple Watch

---

## 🐛 Bugs Conhecidos & Fixes

### 🚨 Issues Pendentes
- [ ] **Preview Não Funciona** - CaptureMethodSelector target missing
  - Solução: Reset Package Caches + Clean Build
- [ ] **TabView Page Style** - macOS compatibility issue
  - Solução: Conditional compilation `#if os(iOS)`
- [ ] **Theme Provider Isolation** - MainActor conflicts
  - Solução: Explicit @MainActor methods

### 🔧 Technical Debt
- [ ] **Code Organization** - Mover previews para arquivos separados
- [ ] **Error Handling** - Unified error handling strategy
- [ ] **Documentation** - Code comments e documentation
- [ ] **Performance Profiling** - Identificar bottlenecks

---

## 📅 Timeline & Milestones

### 🎯 Sprint 1-2 (Atual)
- [x] Infraestrutura básica e Theme Provider
- [x] CaptureButton refatorado para minimalista
- [ ] CaptureMethodSelector funcionando
- [ ] Preview system estável

### 🎯 Sprint 3-4
- [ ] OCR Integration completa
- [ ] Voice Recognition implementado
- [ ] Manual Input form funcional
- [ ] ShoppingListView básico

### 🎯 Sprint 5-6
- [ ] SwiftData models e persistência
- [ ] CloudKit synchronization
- [ ] SavedListsView implementada
- [ ] Basic stats functionality

### 🎯 Sprint 7-8
- [ ] LLM integration finalizada
- [ ] Premium UI polishing
- [ ] Accessibility compliance
- [ ] Performance optimization

### 🎯 Sprint 9-10
- [ ] Advanced features
- [ ] Testing coverage completa
- [ ] Documentation finalizada
- [ ] Beta testing preparation

---

## 💡 Notas & Ideias

### 🧠 Brainstorming
- **Gesture Innovation**: Shake para clear lista atual
- **Smart Suggestions**: LLM para sugerir produtos frequentes
- **Budget Tracking**: Alertas quando próximo do limite
- **Social Features**: Share lists com family/friends
- **MenuButton Enhancement**: Adicionar badge para notificações ou updates

### 📝 Decisões Arquiteturais
- **SwiftUI-Only Policy**: Commitment absoluto, sem exceções
- **Swift 6 Concurrency**: Sendable compliance obrigatório
- **Clean Architecture**: Separação clara de responsabilidades
- **Environment Injection**: Single source of truth para theme
- **MenuAction Pattern**: Enum-based actions para type safety

---

## ✅ Critérios de Conclusão

### 📋 Definition of Done
- [ ] **Zero UIKit imports** - SwiftUI-Only compliance
- [ ] **All previews working** - Development workflow smooth
- [ ] **Tests passing** - Unit, integration e UI tests
- [ ] **Performance targets met** - Launch < 1s, OCR < 300ms
- [ ] **Accessibility validated** - VoiceOver e WCAG 2.1 AA
- [ ] **Code review approved** - Peer review obrigatório

---

*Última atualização: 31 de Maio de 2025*
*Responsável: Equipa CadaEuro*
*Status: Em desenvolvimento ativo 🚧*
