# 📱 CadaEuro - Documentação Completa de Funcionalidades

## 🎯 Visão Geral
CadaEuro é uma aplicação premium de lista de compras para iOS 17+ que ajuda consumidores a controlar em tempo real o total das compras de supermercado. Combina tecnologia avançada (OCR, reconhecimento de voz, LLM) com design elegante inspirado na Apple Store. A app utiliza múltiplos métodos de captura de produtos e oferece uma experiência de utilizador sofisticada com suporte completo à acessibilidade (WCAG 2.1 AA, Dynamic Type).

---

## 🏠 Ecrã Principal (ShoppingListView)

### Interface Central
- **Título**: "CadaEuro - Aplicação de listas de compras" (prioridade 10 de acessibilidade)
- **Visualização do Total**: Valor em destaque com efeito de brilho no modo escuro (€XX.XX)
- **Lista de Itens**: Visualização dinâmica dos produtos adicionados
- **Botões de Captura**: Interface adaptativa para diferentes métodos de entrada

### Funcionalidades Principais

#### 1. Métodos de Captura de Produtos
**🎥 Scanner OCR (VisionKit)**
- Botão principal: "Capturar com câmara"
- Abre interface de scanner com preview da câmara
- Frame de reconhecimento com animação de linha de scan
- Indicadores de canto para delimitar área de captura
- Instruções visuais: "Aponte para a etiqueta"
- Pré-processamento de imagem (binarização via CIImage)
- Reconhecimento OCR on-device < 300ms por item
- Processamento LLM para normalização de texto (GPT-4.1 mini / Gemini 2 Flash)
- Recurso para entrada manual em caso de falha

**🎤 Entrada por Voz (SpeechRecognizer)**
- Botão: "Gravar com microfone"
- Interface de gravação com animação de pulsação
- Reconhecimento de fala em português (Locale pt-PT)
- Transcrição streaming em tempo real
- Processamento LLM para normalização de texto (GPT-4.1 mini / Gemini 2 Flash)
- Confirmação visual do item capturado
- Suporte completo no dispositivo (simulador usa dados mock)

**⌨️ Entrada Manual**
- Botão: "Adicionar manualmente"
- Formulário com campos para produto e preço
- Validação em tempo real
- Teclado numérico para preços
- Botão de adição habilitado apenas com dados válidos

#### 2. Navegação por Gestos
**Deslize Horizontal nas Áreas de Captura**
- Deslize para alternar entre modo câmara/voz ↔ modo manual
- Animação suave de transição (300ms ease-in-out)
- Feedback háptico durante a transição
- Indicadores visuais de modo ativo

**Long Press no Total**
- Abre menu contextual com opções:
  - "Guardar lista" (archivebox icon)
  - "Nova lista" (doc.badge.plus icon)
- Menu posicionado centralmente com overlay escurecido

#### 3. Menu Principal
**Acesso**: Botão de ellipsis no canto superior direito
**Opções disponíveis**:
- 📋 **Listas guardadas**: Acesso às listas salvas
- 📊 **Estatísticas**: Relatórios e análises de gastos
- ⚙️ **Definições**: Configuração e preferências

---

## 📋 Listas Guardadas (SavedListsView) com SwiftData

### Interface e Navegação
- **Header**: "Listas guardadas" com botão de volta
- **Estado Vazio**: Ícone de archivebox com mensagem explicativa
- **Cartões de Lista**: Design minimalista com informações essenciais

### Funcionalidades

#### 1. Visualização de Listas Salvas
**Informações por Cartão**:
- Nome da lista (editável)
- Data de conclusão (formato: "d MMM")
- Número total de itens
- Valor total em euros

**Persistência e Sincronização**:
- Armazenamento local via SwiftData
- Sincronização entre dispositivos via CloudKit
- Resolução de conflitos via última edição

#### 2. Gestão de Listas
**Edição de Nome**:
- Toque no cartão para editar nome inline
- Botões de confirmação (✓) e cancelamento (✗)
- Validação: nome vazio torna-se "Lista de compras"

**Menu Contextual** (Long Press):
- **Renomear**: Edição rápida do nome
- **Apagar**: Remoção com confirmação
- Menu posicionado inteligentemente (cima/baixo conforme posição)

#### 3. Detalhes da Lista (SavedListDetailView)
- **Header**: Nome da lista editável
- **Resumo**: Total, data e contagem de itens
- **Lista Completa**: Todos os produtos com preços
- **Navegação**: Sheet modal com dismiss automático

---

## 📊 Estatísticas (StatsView)

### Interface Principal
- **Background**: Gradiente para light mode, dark sólido para dark mode
- **Navegação Mensal**: Gestos de deslize ou selector de período
- **Indicadores**: Limitação inteligente de navegação

### Funcionalidades de Análise

#### 1. Visualização Temporal
**Navegação por Mês/Ano**:
- Deslize esquerda/direita para navegar
- Botão de seletor quando atinge limites
- Formato: "Mês Ano" (ex: "Janeiro 2025")

#### 2. Métricas Calculadas
**Dados Exibidos**:
- **Total Gasto**: Soma de todas as listas do período
- **Média por Lista**: Valor médio das compras
- **Número de Listas**: Contagem de listas completadas
- **Filtros**: Baseado em data de conclusão

#### 3. Picker de Período
- **Interface Modal**: Sheet com seletores
- **Anos Disponíveis**: 2020 até ano atual
- **Meses**: Janeiro a Dezembro
- **Validação**: Não permite datas futuras

---

## ⚙️ Definições (SettingsView)

### Estrutura Organizada
**Seções Principais**:
1. **Conta**: Gestão de plano e compras
2. **Dados**: Import/Export de informações
3. **Personalização**: Aparência e preferências
4. **Acessibilidade**: Opções inclusivas
5. **Suporte**: Ajuda e informações

### Funcionalidades Detalhadas

#### 1. Gestão de Conta
- **Gerir plano PRO**: Acesso a funcionalidades premium
- **Restaurar compras**: Recuperação de compras anteriores

#### 2. Gestão de Dados
- **Exportar listas**: Backup das informações
- **Importar dados**: Toggle para importação automática

#### 3. Personalização
**Aparência**:
- **Tamanho do texto**: Pequeno, Médio, Grande
- **Moeda**: Euro (padrão), outras opções

**Sistema**:
- **Notificações**: Toggle de ativação
- **Alto contraste**: Para melhor visibilidade

#### 4. Acessibilidade
- **Tamanho de texto acessível**: Suporte a Dynamic Type
- **Contraste elevado**: Melhoria de legibilidade
- **Redução de movimento**: Animações simplificadas

#### 5. Suporte
- **Sobre**: Informações da aplicação e versão

---

## 🎨 Design System e Interações

### Identidade Visual
**Estética**: Inspirada na Apple Store
- **Cores Adaptativas**: Suporte completo light/dark mode
- **Tipografia**: San Francisco com pesos consistentes
- **Espaçamento**: Grid de 8px com tokens específicos
- **Acessibilidade**: Conformidade HIG, WCAG 2.1 AA, Dynamic Type até XXL
- **Contraste**: Mínimo 4.5:1 para todos os elementos

### Microinterações Premium

#### 1. Feedback Háptico
- **Light**: Interacções básicas (toques, deslizes)
- **Medium**: Mudanças de estado
- **Rigid**: Ações importantes (delete, save)
- **Success**: Confirmações positivas

#### 2. Animações Contextuais
**Spring Animations**:
- Response: 0.3-0.5
- Damping: 0.7-0.8
- Uso: Menus, modais, transições

**Scale Effects**:
- Botões: 0.95x quando pressionados
- Menus: 1.05x quando ativos
- Duração: 100-150ms

#### 3. Estados Visuais
**Botões**:
- **Idle**: Estado padrão com sombras
- **Pressed**: Redução de escala + feedback háptico
- **Disabled**: Opacidade reduzida

**Elementos Interativos**:
- **Hover** (iPad/Mac): Brilho aumentado
- **Foco**: Bordas destacadas para acessibilidade
- **Carregamento**: Animações de progresso

---

## ♿ Acessibilidade Premium

### Suporte Completo a VoiceOver
**Hierarquia de Navegação**:
1. **Prioridade 10**: Header e menu principal
2. **Prioridade 9**: Seção do total
3. **Prioridade 5**: Botões de captura
4. **Prioridade 2**: Lista de itens

### Labels e Hints Descritivos
**Exemplos Implementados**:
- "Capturar com câmara" + "Abre scanner para códigos de barras"
- "Total da lista: X.XX euros" + "Prima e mantenha premido para opções"
- "Menu de opções" + "Abre menu com listas, estatísticas e definições"

### Dynamic Type e Contrastes
- **Fontes Escaláveis**: Suporte completo a accessibility sizes
- **Contraste Automático**: Ajustes baseados em preferências
- **Cores Diferenciadas**: Sem dependência apenas de cor
- **Movimento Reduzido**: Animações opcionais

---

## 🗂️ Gestão de Dados

### Modelo de Dados (SwiftData + CloudKit)

#### ShoppingItem
```swift
- id: UUID (único)
- name: String (nome do produto)
- price: Double (preço unitário)
- quantity: Int (quantidade)
- category: String? (categoria opcional)
- barcode: String? (código de barras)
- notes: String? (notas do utilizador)
- dateAdded: Date (data de criação)
- dateModified: Date (última modificação)
- captureMethod: CaptureMethod (método de captura)
```

#### ShoppingList
```swift
- id: UUID (identificador único)
- name: String (nome da lista)
- dateCreated: Date (data de criação)
- dateModified: Date (última modificação)
- completedDate: Date? (data de conclusão)
- isCompleted: Bool (status da lista)
- estimatedTotal: Double (total estimado)
- actualTotal: Double? (total real)
- items: [ShoppingItem] (produtos da lista)
```

#### CaptureMethod (Enum)
```swift
- .scanner: Captura via câmara
- .voice: Captura via microfone
- .manual: Entrada manual
```

### Operações de Dados
**CRUD Completo**:
- **Create**: Adição de itens e listas
- **Read**: Consulta com filtros e ordenação
- **Update**: Edição inline e modificações
- **Delete**: Remoção com confirmação

**Persistência & Sincronização**:
- Salvamento automático via SwiftData
- Sincronização CloudKit em tempo real
- Database privada com record zones por utilizador
- Resolução de conflitos via última edição
- NSFileProtectionCompleteUntilFirstUserAuthentication

---

## 🔧 Funcionalidades Técnicas

### Arquitetura Clean Architecture
**Separação de Responsabilidades**:
- **Presentation**: Vistas SwiftUI, temas, design system
- **Domain**: Casos de uso (AddItem, ComputeTotal)
- **Data**: Repositórios (ItemRepository, SettingsRepository)
- **Core**: Utilitários, telemetry, extensões

### Captura Inteligente
**Scanner OCR (VisionKit)**:
- Preview em tempo real
- TextRecognizer com pré-processamento CIImage (binarização)
- Reconhecimento OCR on-device < 300ms por item
- Normalização de texto via LLM
- Recurso para entrada manual

**Reconhecimento de Voz (SpeechRecognizer)**:
- Locale pt-PT com transcrição streaming
- Processamento local (privacidade)
- Normalização via GPT-4.1 mini / Gemini 2 Flash
- Cache de respostas LLM (NSCache 5 min.)

### Validação e Tratamento de Erros
**Validações Implementadas**:
- Nomes de produtos (não vazios, máx. 100 caracteres)
- Preços (valores positivos, máx. €9999.99)
- Quantidades (1-999 unidades)

**Tratamento de Erros**:
- ValidationError personalizado
- Mensagens localizadas em português
- Feedback visual claro para o utilizador

---

## 🎯 Fluxos de Utilizador Principais

### 1. Adicionar Item por OCR
1. Toque no botão "Capturar com câmara"
2. Apontar câmara para preço no recibo
3. Processamento de imagem e reconhecimento OCR (< 300ms)
4. Normalização do texto via LLM (GPT-4.1 mini / Gemini 2 Flash)
5. Confirmar/editar produto e preço
6. Item adicionado à lista e persistido via SwiftData
7. Sincronização automática via CloudKit

### 2. Adicionar Item por Voz
1. Toque no botão "Gravar com microfone"
2. Dizer nome do produto e preço
3. Transcrição streaming em tempo real
4. Normalização via LLM (GPT-4.1 mini / Gemini 2 Flash)
5. Confirmar informações capturadas
6. Item salvo na lista atual via SwiftData
7. Sincronização automática via CloudKit

### 3. Adicionar Item Manualmente
1. Deslize para modo manual OU toque em "Adicionar manualmente"
2. Preencher campos obrigatórios
3. Validação em tempo real
4. Toque em "Adicionar" (habilitado apenas se válido)
5. Item inserido na lista

### 4. Gerenciar Listas
1. Long press no total para menu de lista
2. Escolher "Guardar lista" ou "Nova lista"
3. Lista atual arquivada se guardada
4. Nova lista criada automaticamente
5. Continuar comprando na nova lista

### 5. Visualizar Estatísticas
1. Menu principal > "Estatísticas"
2. Navegar por meses com deslize
3. Ver métricas calculadas automaticamente
4. Usar seletor para datas específicas
5. Analisar padrões de gasto

---

## 📱 Estados da Aplicação

### Gestão de Estado
**State Container**:
- @Observable (Swift 5.9)
- ViewModel por ecrã
- Reducers isolados para facilitar testes

### Estados Visuais
**Lista Vazia**:
- Instruções claras para começar
- Botões de captura destacados
- Mensagem motivacional

**Lista com Itens**:
- Total prominente no topo
- Cards de produtos organizados
- Deslizar para eliminar disponível

**Carregamento**:
- Indicadores de progresso
- Feedback durante processamento
- Estados intermediários claros

### Estados de Interação
**Navegação**:
- Transições suaves entre ecrãs
- Breadcrumbs visuais
- Botões de volta consistentes

**Edição**:
- Modo de edição inline
- Confirmação/cancelamento
- Validação em tempo real

**Menu/Modal**:
- Sobreposições com dispensa por toque
- Posicionamento inteligente
- Animações de entrada/saída

---

## 🌟 Diferenciais do CadaEuro

### Inovação Tecnológica
1. **Múltiplos Métodos de Captura**: Scanner, voz e manual
2. **Interface Adaptativa**: Deslize para alternar modos
3. **Reconhecimento Inteligente**: IA para processar fala
4. **Design Responsivo**: Suporte completo a accessibility

### Experiência Premium
1. **Microinterações Sofisticadas**: Feedback háptico em todas as ações
2. **Animações Contextuais**: Spring animations naturais
3. **Dark Mode Premium**: Glow effects e contrastes otimizados
4. **Acessibilidade Total**: VoiceOver, Dynamic Type, contraste

### Funcionalidades Exclusivas
1. **Estatísticas Avançadas**: Análise temporal de gastos
2. **Gestão Inteligente**: Auto-arquivamento e organização
3. **Validação Robusta**: Prevenção de erros de entrada
4. **Design System Coeso**: Tokens centralizados e consistentes


---

## 📞 Suporte e Documentação

### Para Desenvolvedores
- **Arquitetura Documentada**: Clean Architecture com exemplos
- **Design System Completo**: Tokens, componentes e guidelines
- **Testes Abrangentes**: Unitários, UI e acessibilidade
- **Performance Otimizada**: SwiftData e concorrência moderna

### Para Utilizadores
- **Onboarding Intuitivo**: Tutorial interativo
- **Ajuda Contextual**: Dicas e hints em tempo real
- **FAQ Completo**: Respostas para dúvidas comuns
- **Suporte Multilíngue**: Português,ingles e frances 

---

## 🎉 Conclusão

CadaEuro representa o estado da arte em aplicações de lista de compras, combinando:

✅ **Tecnologia Avançada**: IA, reconhecimento de voz, scanner OCR
✅ **Design Premium**: Inspirado na Apple Store com microinterações
✅ **Acessibilidade Total**: Suporte completo a utilizadores com necessidades especiais
✅ **Experiência Fluida**: Gestos intuitivos e feedback imediato
✅ **Arquitetura Robusta**: Clean Architecture com SwiftData
✅ **Performance Otimizada**: Animações suaves e responsividade

A aplicação estabelece um novo padrão para experiência do utilizador em produtividade móvel, priorizando tanto a funcionalidade quanto a elegância visual.

---

*Última atualização: 29 de Maio de 2025*
*Versão: 1.0.0*
*Plataforma: iOS 17.0+*
