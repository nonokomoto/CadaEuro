# CadaEuro Design System

## 🎨 Visão Geral

O CadaEuro é uma aplicação premium para iOS 17+ que ajuda consumidores a controlar em tempo real o total das compras de supermercado através de OCR, voz e entrada manual. Adota uma estética **Apple Store minimalista** com foco na elegância, simplicidade e funcionalidade. O design é construído com base nos princípios de design da Apple, oferecendo uma experiência premium e sofisticada, com total conformidade às diretrizes WCAG 2.1 AA e Human Interface Guidelines.

---

## 🖌️ ThemeProvider e Gestão de Estado

Para garantir a consistência visual e o alinhamento total ao Design System, todas as views SwiftUI devem aceder ao tema global através do ThemeProvider, que é injectado no ponto de entrada da app.

- Usa sempre `@Environment(\.themeProvider) private var themeProvider` nas tuas views para aceder ao tema.
- Nunca criar instâncias locais de AppTheme ou duplicar tokens; usa sempre o tema global.
- Implementa State Container com `@Observable` (Swift 5.9) + ViewModel por ecrã.
- Exemplo:

```swift
struct ExemploView: View {
    @Environment(\.themeProvider) private var themeProvider
    @State private var viewModel = ExemploViewModel()
    
    var body: some View {
        Text("Olá")
            .font(themeProvider.theme.typography.titleLarge)
            .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
    }
}
```

- Garante que todas as views relevantes estão dentro da hierarquia `.withThemeProvider(themeProvider)` (ver ponto de entrada da app).
- Utiliza Reducers isolados para facilitar testes.

---

## 💼 Componentes Reutilizáveis

Todos os componentes visuais reutilizáveis (botões, cards, inputs, etc.) do Design System estão implementados no Swift Package `CadaEuroUI`:

```
CadaEuroUI/Sources/Components/
```

> Utilize sempre estes componentes para garantir consistência visual e aderência ao Design System.

Os tokens de tema (cores, tipografia, espaçamento, etc.) continuam centralizados em `CadaEuroUI/Sources/Theme`.

A arquitetura modular baseada em Swift Packages garante a separação rigorosa de responsabilidades:

---

## 🎨 Paleta de Cores

### Modo Claro (Light Mode)
- **Background Principal**: `#F8F9FA` (Cinza sofisticado luxury)
- **Gradiente de Fundo**: `#F5F5F7` (Apple premium gray)
- **Cards/Componentes**: Branco com 85% de opacidade
- **Texto Primário**: `#1C1C1E` (Preto Apple)
- **Texto Secundário**: `#3C3C43` (Cinza médio)
- **Texto Terciário**: `#8E8E93` (Cinza claro)
- **Azul Destaque**: `#007AFF` (Apple System Blue)

### Modo Escuro (Dark Mode)
- **Background Principal**: `#000000` (Preto puro Apple Store)
- **Cards/Componentes**: `#1C1C1E` (Cinza escuro Apple)
- **Texto Primário**: `#FFFFFF` (Branco puro)
- **Texto Secundário**: `#EBEBF5` com 60% opacidade
- **Texto Terciário**: `#EBEBF5` com 30% opacidade
- **Azul Destaque**: `#007AFF` (Apple System Blue)
- **Glow Azul**: `#007AFF` com 40% opacidade (apenas dark mode)

---

## 📝 Tipografia

### Hierarquia de Texto
- **Total Principal**: 48pt, Medium, Design Default
- **Títulos de Seção**: 28pt, Medium/Bold
- **Subtítulos**: 20pt, Medium
- **Corpo Principal**: 18pt, Medium/Regular
- **Corpo Secundário**: 17pt, Regular
- **Labels Pequenos**: 16pt, Regular
- **Captions**: 14pt, Medium
- **Labels Mínimos**: 12pt, Medium

### Fonte Sistema
- **Família**: SF Pro (Sistema iOS)
- **Variações**: Regular, Medium, Bold
- **Adaptável**: Suporte completo ao Dynamic Type

---

## 🧩 Componentes

### 1. Total Display
```
€23.68
- Tamanho: 48pt
- Peso: Medium
- Cor: #007AFF (Apple System Blue)
- Glow: Azul (apenas dark mode)
- Posição: Centro superior
- Interação: Long press para menu
```

### 2. Item Cards
```
🥛 2L Leite Meio Gordo    €1.49
- Background: Card adaptativo
- Padding: 24px horizontal, 20px vertical
- Border Radius: 16px
- Emoji: 24pt à esquerda
- Nome: 18pt Medium
- Preço: 18pt Medium, cor azul
- Swipe Actions: Apagar (vermelho)
```

### 3. Botões Principais de Captura
```
OCR [📷]  Voz [🎤]  Manual [⌨️]
- Tamanho: 70x70px círculos
- Ícone: 24pt Medium
- Background: Card adaptativo
- Border: 1px stroke
- Shadow: 8px radius, 4px offset Y
- Espaçamento: 40px entre botões
- Acessibilidade: Touch target mínimo 44pt
- Labels: "Scanner OCR (VisionKit)", "Entrada por Voz (SpeechRecognizer)", "Entrada Manual"
```

### 4. Indicadores de Modo
```
● ● ○
- Tamanho: 6x6px círculos
- Ativo: #007AFF (azul)
- Inativo: Texto terciário
- Espaçamento: 8px entre pontos
```

### 5. Menu Contextual
```
┌─────────────────────┐
│ 📋 Listas guardadas │
│ ─────────────────── │
│ 📊 Estatísticas     │
│ ─────────────────── │
│ ⚙️ Definições       │
└─────────────────────┘
- Width: 240px
- Background: Card adaptativo
- Border Radius: 16px
- Item Height: 56px
- Shadow: 8px radius
```

---

## 📱 Layout e Espaçamento

### Estrutura Principal
```
┌─── Header (20px top) ───┐
│ CadaEuro          ⋯    │
├─── Total (60px top) ────┤
│       €23.68           │
├─── Lista (80px gap) ────┤
│ 🥛 Item 1        €1.49 │
│ 🍌 Item 2        €1.29 │
│ 🥚 Item 3        €1.65 │
├─── Botões (40px top) ───┤
│    📷      🎤          │
│      ● ● ○            │
└─────────────────────────┘
```

### Margens e Padding
- **Lateral Global**: 20px
- **Entre Seções**: 40-80px
- **Cards Internos**: 24px horizontal, 20px vertical
- **Botões do Total**: 60px do topo
- **Botões Principais**: 40px do scroll view

---

## 🎭 Estados Visuais

### Interações
- **Botão Pressionado**: Scale 0.9 (150ms ease-in-out)
- **Menu Ativo**: Scale 0.9 (250ms ease-in-out)
- **Haptic Feedback**: Light, Medium, Rigid conforme ação

### Transições
- **Modo Switch**: 300ms ease-in-out
- **Menu Appearance**: 250ms ease-out
- **Card Swipe**: Sistema padrão iOS

### Sombras
- **Cards**: 8px radius, 4px offset Y, cor adaptativa
- **Menus**: 8px radius, 4px offset Y, preto 30% opacidade

---

## 📊 Componentes de Dados

### Estatísticas Cards (SwiftData)
```
💰 Total gasto: €156.32
📋 Listas criadas: 12
📈 Média por lista: €13.03
- Layout: Ícone + Label + Valor
- Cores: Ícone terciário, texto primário, valor azul
- Dados: Consultas SwiftData otimizadas
- Sincronização: CloudKit em tempo real
```

### Gráfico de Barras
```
▇ ▅ ▇ ▃ ▆ ▇ ▄ ▅
- Cor: #007AFF (azul)
- Width: 20px por barra
- Height: Máximo 150px
- Corner Radius: 3px
```

---

## 🔧 Tokens de Design

### Border Radius
- **Cards**: 16px
- **Botões Pequenos**: 12px
- **Botões Circulares**: 50% (círculo perfeito)

### Opacidades
- **Cards Light**: 85%
- **Texto Secundário Dark**: 60%
- **Texto Terciário Dark**: 30%
- **Menu Background**: 85%

### Elevações
- **Nível 1**: 4px offset, 8px blur
- **Nível 2**: 8px offset, 16px blur
- **Glow Effect**: 0px offset, 12px blur + 4px blur

---

## 🌙 Adaptação Dark/Light Mode

### Automática
- Utiliza `UITraitCollection.current.userInterfaceStyle`
- Tokens de cor adaptativos
- Glow effect apenas no dark mode
- Transições suaves entre modos

### Testes de Contraste
- **Ratio Mínimo**: 4.5:1 (WCAG AA)
- **Texto sobre Backgrounds**: Testado em ambos os modos
- **Elementos Interativos**: Contraste mínimo 3:1

---

## 🎯 Princípios de Design

### 1. **Minimalismo Apple**
- Elementos essenciais apenas
- Hierarquia visual clara
- Espaço em branco generoso

### 2. **Funcionalidade Premium**
- Interações intuitivas
- Feedback háptico apropriado
- Performance fluida (60fps)

### 3. **Consistência**
- Tokens de design centralizados
- Padrões reutilizáveis
- Comportamentos previsíveis

### 4. **Acessibilidade**
- Dynamic Type support
- VoiceOver compatibility
- Contraste adequado
- Touch targets mínimos 44pt

---

## 📋 Guidelines de Implementação

### SwiftUI Tokens (Swift Packages)
```swift
// Importação do package UI
import CadaEuroUI

// Cores adaptativas
themeProvider.theme.colors.background
themeProvider.theme.colors.textPrimary
themeProvider.theme.colors.totalPrice
themeProvider.theme.colors.itemBackground

// Tipografia
themeProvider.theme.typography.totalPrice // .system(size: 48, weight: .medium, design: .default)

// Espaçamentos
.padding(.horizontal, themeProvider.theme.spacing.horizontalStandard) // 20
.padding(.vertical, themeProvider.theme.spacing.verticalStandard) // 16
```

### Estados de Interação (Swift Packages)
```swift
// Importação do package de utilitários
import CadaEuroKit

// Animações
.animation(.easeInOut(duration: themeProvider.theme.animation.standardDuration), value: state)
.scaleEffect(isPressed ? themeProvider.theme.animation.pressedScale : 1.0)

// Feedback
HapticManager.shared.feedback(.light)
HapticManager.shared.feedback(.medium)
HapticManager.shared.feedback(.rigid)
```

---

## 🚀 Diretrizes Futuras

### Expansibilidade
- Sistema de tokens preparado para novas features
- Componentes modulares e reutilizáveis via Swift Packages
- Suporte a múltiplos tamanhos de tela
- Modularização para futura porta Android

### Performance
- Lazy loading para listas grandes
- Otimização de renderização
- Caching de componentes pesados
- Tempo de arranque cold < 1s
- Reconhecimento OCR < 300ms por item
- Cache de respostas LLM (NSCache 5 min.)

### Internacionalização
- Layouts flexíveis para textos longos
- Suporte RTL futuro
- Tokens de espaçamento adaptativos

---

## ♿ Acessibilidade e Inclusividade

### Princípios de Acessibilidade
O CadaEuro segue as diretrizes WCAG 2.1 AA e as melhores práticas de acessibilidade da Apple para garantir uma experiência inclusiva para todos os utilizadores, com:
- **AccessibilityLabel** para todos os elementos interativos
- **Suporte VoiceOver** com rotulagem ordenada
- **Dynamic Type** escalável até XXL
- **Contraste mínimo** 4.5:1

### Contraste de Cores
- **Texto Principal**: Contraste mínimo de 4.5:1 em todos os modos
- **Texto Secundário**: Contraste mínimo de 3:1 para elementos informativos
- **Elementos Interativos**: Contraste mínimo de 3:1 para bordas e estados de foco

### Suporte a Dynamic Type
```swift
// Todas as fontes suportam Dynamic Type
.font(.system(size: 18, weight: .medium))
.dynamicTypeSize(.accessibility1...accessibility5)
```

### Navegação por Teclado/VoiceOver
- **Ordem de Tabulação**: Lógica e intuitiva (topo → baixo, esquerda → direita)
- **Labels Descritivos**: Todos os elementos interativos têm labels claros
- **Hints Contextuais**: Instruções claras para ações complexas
- **Estados Anunciados**: Mudanças de estado são comunicadas ao VoiceOver

### Textos Alternativos
```swift
// Exemplo de implementação
.accessibilityLabel("Adicionar item à lista")
.accessibilityHint("Toque duplo para abrir opções de captura")
.accessibilityValue("Total atual: €23.68")
```

### Feedback Háptico Inclusivo
- **Light**: Confirmações e navegação
- **Medium**: Seleções e mudanças de modo
- **Rigid**: Ações destrutivas e alertas
- **Success/Error**: Feedback de resultado de ações

### Suporte a Modo de Alto Contraste
```swift
@Environment(\.accessibilityReduceTransparency) var reduceTransparency
@Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
```

### Animações Respeitosas
- **Reduce Motion**: Animações essenciais mantidas, decorativas removidas
- **Duração Ajustável**: Animações mais lentas para utilizadores que precisam
- **Alternativas Estáticas**: Estados finais claros sem dependência de movimento

### Tamanhos de Toque Acessíveis
- **Mínimo**: 44x44pt para todos os elementos interativos
- **Recomendado**: 48x48pt para ações principais
- **Espaçamento**: Mínimo 8pt entre elementos tocáveis

### Cores e Símbolos Inclusivos
- **Não Dependência de Cor**: Informação nunca transmitida apenas por cor
- **Símbolos Universais**: Ícones reconhecíveis internacionalmente
- **Redundância Visual**: Múltiplas formas de comunicar o mesmo estado

---

## 🎯 Microinterações e Feedback Visual

### Princípios de Microinteração
- **Propósito Claro**: Cada animação tem uma função específica
- **Duração Apropriada**: 150-300ms para feedback, 300-600ms para transições
- **Easing Natural**: Curvas de animação que imitam movimento físico
- **Feedback Imediato**: Resposta visual instantânea a toques

### Animações de Feedback
```swift
// Botão pressionado
.scaleEffect(isPressed ? 0.98 : 1.0)
.animation(.easeInOut(duration: 0.15), value: isPressed)

// Item adicionado
.scaleEffect(showAddAnimation ? 1.2 : 1.0)
.animation(.spring(response: 0.3, dampingFraction: 0.6), value: showAddAnimation)

// Total atualizado
.scaleEffect(pulseAnimation ? 1.02 : 1.0)
.animation(.easeInOut(duration: 0.3), value: pulseAnimation)
```

### Estados Visuais Aprimorados
- **Idle**: Estado padrão com sombras sutis
- **Hover**: Ligeiro aumento de brilho (iPad/Mac)
- **Pressed**: Redução de escala (0.98x) + mudança de cor
- **Loading**: Animação de rotação ou pulsação
- **Success**: Escala aumentada + cor de sucesso
- **Error**: Vibração sutil + cor de erro

### Transições de Contexto
- **Slide**: Para navegação hierárquica
- **Scale**: Para modais e overlays
- **Fade**: Para mudanças de estado
- **Spring**: Para feedback de ações

---

## 🔄 Melhorias Implementadas

### 1. Microinterações Aprimoradas
✅ **Feedback Visual Evidente**
- Animações de escala em botões (0.98x quando pressionado)
- Efeito ripple em botões de captura
- Pulsação no total quando valor muda
- Animação de entrada para novos itens

✅ **Transições Suaves**
- Spring animations para menus (response: 0.3, damping: 0.8)
- Easing natural para todas as transições
- Delays escalonados para elementos múltiplos

### 2. Background Aprimorado
✅ **Gradientes Suaves**
- Gradiente multi-stop para modo claro
- Gradiente premium para modo escuro
- Elementos flutuantes sutis para interesse visual

✅ **Microanimações de Fundo**
- Círculos flutuantes com movimento lento
- Opacidade reduzida para não interferir
- Animação contínua com autoreverso

### 3. Componentes Aprimorados
✅ **Cards de Item Melhorados**
- Emojis contextuais baseados no nome do produto
- Indicadores de método de captura estilizados
- Animações de entrada e saída suaves
- Feedback háptico em interações

✅ **Menu Contextual Aprimorado**
- Animação de escala e opacidade
- Estados de pressed para botões
- Sombras aprimoradas
- Transições mais fluidas

### 4. Acessibilidade Aprimorada
✅ **Suporte VoiceOver Completo**
- Labels descritivos para todos os elementos
- Hints contextuais para ações complexas
- Valores dinâmicos anunciados
- Ordem de navegação lógica

✅ **Feedback Háptico Estruturado**
- Light: Navegação e confirmações
- Medium: Seleções e mudanças
- Rigid: Ações destrutivas
- Success/Error: Resultados de ações

### 5. Estados Visuais Aprimorados
✅ **Loading States**
- Indicadores de progresso animados
- Mensagens contextuais
- Animações de rotação suaves

✅ **Empty States**
- Ícones animados
- Texto explicativo claro
- Animações de entrada escalonadas

✅ **Success States**
- Checkmarks animados
- Escalas dinâmicas
- Cores de feedback apropriadas

---

## 📋 Próximos Passos Sugeridos

### Testes de Usabilidade
1. **Protótipo Navegável**: Criar versão interativa para testes
2. **Usuários Reais**: Testar com 5-8 utilizadores representativos
3. **Cenários de Uso**: Simular compras reais completas
4. **Feedback Estruturado**: Questionários pós-teste padronizados

### Ajustes de Microinterações
1. **Timing Refinement**: Ajustar durações baseado em feedback
2. **Easing Curves**: Otimizar curvas de animação
3. **Haptic Patterns**: Refinar padrões de feedback háptico
4. **Performance**: Otimizar animações para dispositivos mais antigos

### Acessibilidade Final
1. **Audit Completo**: Revisão com ferramentas de acessibilidade
2. **Teste com VoiceOver**: Navegação completa apenas com VoiceOver
3. **Alto Contraste**: Teste em modo de alto contraste
4. **Dynamic Type**: Teste com tamanhos extremos de fonte

### Dark Mode Refinement
1. **Glow Effects**: Ajustar intensidade dos glows
2. **Contrast Ratios**: Verificar todos os contrastes
3. **Color Harmony**: Refinar harmonia entre cores
4. **Transition Smoothness**: Suavizar transição entre modos

*Design System CadaEuro v1.0 - Desenvolvido com foco na excelência visual e experiência do utilizador Apple.*

*Última atualização: 30 de Maio de 2025*
*Plataforma: iOS 17.0+* 