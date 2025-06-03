import SwiftUI
import CadaEuroKit

/// Ecrã principal da aplicação CadaEuro
///
/// Este é o View central que orquestra todos os componentes finalizados:
/// - TotalDisplay para valor em destaque
/// - CaptureMethodSelector para métodos de captura
/// - Lista de ItemCard para produtos
/// - EmptyStateView quando lista vazia
/// - VoiceRecorderView inline
/// - ManualInputForm via sheet
/// - ScannerOverlay via fullScreenCover
///
/// ## Arquitetura Component Composition
/// ShoppingListView = Integração de building blocks prontos
/// Zero desenvolvimento de novos componentes - apenas orquestração
///
/// ## Integração com Componentes Existentes
/// ```swift
/// TotalDisplay(amount: total, onSaveList: {}, onNewList: {})
/// CaptureMethodSelector(selectedMethod: $method, onSelection: {})
/// ItemCard(item: product, onDelete: {}, onEdit: {})
/// ```
public struct ShoppingListView: View {
    @Environment(\.themeProvider) private var themeProvider
    @StateObject private var viewModel = ShoppingListViewModel()
    
    // MARK: - State Management
    @State private var selectedCaptureMethod: CaptureMethod = .scanner
    @State private var showingManualInput = false
    @State private var showingScanner = false
    @State private var showingVoiceRecorder = false
    @State private var showingSavedLists = false
    @State private var showingStats = false
    @State private var showingSettings = false
    
    // MARK: - Scanner Confirmation State
    @State private var scannedProductData: ProductData?
    @State private var voiceProcessedData: ProductData?
    
    public init() {}
    
    // MARK: - Internal Access for Previews
    internal var internalViewModel: ShoppingListViewModel {
        viewModel
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Background principal
                themeProvider.theme.colors.cadaEuroBackground
                    .ignoresSafeArea()
                
                // Conteúdo principal
                mainContent
                
                // ✅ Voice Recorder Overlay contextual no local do botão de voz
                // Animação estilo Apple onde o overlay substitui o botão suavemente
                if showingVoiceRecorder {
                    voiceRecorderOverlayPositioned
                }
            }
            .onPreferenceChange(CaptureButtonPositionKey.self) { positions in
                if let captureButtonsPosition = positions["capture_buttons_container"] {
                    captureButtonsFrame = captureButtonsPosition
                }
            }
            .navigationTitle("")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "cart")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeProvider.theme.colors.cadaEuroTextPrimary)
                }
                #endif
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                toolbarContent
            }
            // Sheets e Modais
            .sheet(isPresented: $showingManualInput) {
                manualInputSheet
            }
            #if os(iOS)
            .fullScreenCover(isPresented: $showingScanner) {
                scannerView
            }
            #else
            .sheet(isPresented: $showingScanner) {
                scannerView
            }
            #endif
            .sheet(isPresented: $showingSavedLists) {
                savedListsView
            }
            .sheet(isPresented: $showingStats) {
                statsView
            }
            .sheet(isPresented: $showingSettings) {
                settingsView
            }
            // Accessibility
            .accessibilityElement(children: .contain)
            .accessibilityLabel("CadaEuro - Aplicação de listas de compras")
            .accessibilityAddTraits(.isStaticText)
        }
        .logLifecycle(viewName: "ShoppingListView")
    }
    
    // MARK: - Main Content Layout
    
    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 0) {
            // 3. Total (centro, proeminente) - PRIORIDADE ALTA
            totalSection
            
            // 4. Lista/empty state (conteúdo principal) - Flex space
            contentSection
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Usar todo o espaço disponível
            
            // 5. Botões de captura (em baixo) - PRIORIDADE MÉDIA-ALTA
            captureMethodsSection
        }
    }
    // MARK: - Total Section
    
    @ViewBuilder
    private var totalSection: some View {
        VStack(spacing: themeProvider.theme.spacing.lg) {
            // ✅ Componente TotalDisplay finalizado - AUMENTADO para maior destaque
            TotalDisplay(
                amount: viewModel.totalAmount,
                state: viewModel.totalAmount == 0 ? .empty : .normal,
                onSaveList: {
                    CadaEuroLogger.analytics("save_list_tapped", properties: [
                        "items_count": String(viewModel.items.count),
                        "total_amount": String(viewModel.totalAmount)
                    ])
                    viewModel.saveCurrentList()
                },
                onNewList: {
                    CadaEuroLogger.analytics("new_list_tapped", properties: [
                        "previous_items": String(viewModel.items.count),
                        "previous_total": String(viewModel.totalAmount)
                    ])
                    viewModel.startNewList()
                }
            )
            .scaleEffect(1.2) // Aumentar 20% para maior proeminência
            .padding(.vertical, themeProvider.theme.spacing.md) // Mais espaço vertical
            
        }
        .padding(.horizontal, themeProvider.theme.spacing.xl) // Mais padding horizontal
        .padding(.top, themeProvider.theme.spacing.lg) // Mais padding superior
    }
    
    // MARK: - Capture Methods Section
    
    @ViewBuilder
    private var captureMethodsSection: some View {
        VStack(spacing: themeProvider.theme.spacing.md) {
            
            
            // ✅ Componente CaptureMethodSelector finalizado - AUMENTADO para maior destaque
            CaptureMethodSelector(
                isVoiceButtonHidden: $showingVoiceRecorder,
                onMethodSelected: { method in
                    CadaEuroLogger.ui("Capture method selected", component: "CaptureMethodSelector", metadata: [
                        "method": method.analyticsName,
                        "previous_method": selectedCaptureMethod.analyticsName
                    ])
                    
                    selectedCaptureMethod = method
                    handleCaptureMethodSelection(method)
                },
                onVoiceLongPressStart: {
                    CadaEuroLogger.ui("Voice long press started", component: "CaptureMethodSelector", metadata: [
                        "trigger": "long_press_start"
                    ])
                    showingVoiceRecorder = true
                },
                onVoiceLongPressEnd: {
                    CadaEuroLogger.ui("Voice long press ended", component: "CaptureMethodSelector", metadata: [
                        "trigger": "long_press_end"
                    ])
                    // ✅ CORRIGIDO: NÃO fechar o overlay automaticamente - deixar o overlay gerenciar a gravação
                    // O overlay permanece aberto para o usuário decidir cancelar ou completar a gravação
                }
            )
            .scaleEffect(1.15) // Aumentar 15% para maior destaque
            .padding(.vertical, themeProvider.theme.spacing.sm) // Reduzir espaço vertical
        }
        .padding(.horizontal, themeProvider.theme.spacing.xl) // Manter padding horizontal
        .padding(.top, themeProvider.theme.spacing.md) // Apenas padding superior
        .padding(.bottom, themeProvider.theme.spacing.sm) // Padding inferior mínimo
        // ✅ REMOVIDO: background cinzento para eliminar campo visual extra
    }
    
    // MARK: - Content Section
    
    @ViewBuilder
    private var contentSection: some View {
        if viewModel.items.isEmpty {
            // Empty state expandido para ocupar espaço disponível
           VStack(alignment: .center, spacing: 0) {
            emptyStateSection
            Spacer()
           }
        } else {
            // Lista de items com scroll
            itemsListSection
        }
    }
    
    // MARK: - Empty State Section
    
    @ViewBuilder
    private var emptyStateSection: some View {
        // ✅ Componente EmptyStateView finalizado
        EmptyStateView(type: .newShoppingList)
            .padding(.horizontal, themeProvider.theme.spacing.lg)
            .padding(.top, themeProvider.theme.spacing.lg)
            .padding(.bottom, themeProvider.theme.spacing.lg)
    }
    
    // MARK: - Items List Section
    
    @ViewBuilder
    private var itemsListSection: some View {
        ScrollView {
            LazyVStack(spacing: themeProvider.theme.spacing.md) {
                ForEach(viewModel.items.sorted { $0.dateAdded > $1.dateAdded }) { item in
                    // ✅ Componente ItemCard finalizado
                    ItemCard(
                        item: ShoppingItem(
                            name: item.name,
                            price: item.price,
                            quantity: item.quantity,
                            captureMethod: item.captureMethod,
                            dateAdded: item.dateAdded
                        ),
                        onDelete: {
                            CadaEuroLogger.ui("Item deleted via swipe", component: "ItemCard", metadata: [
                                "item_name": item.name,
                                "item_price": String(item.price),
                                "total_items": String(viewModel.items.count)
                            ])
                            viewModel.deleteItem(item)
                        }
                    )
                }
            }
            .padding(.horizontal, themeProvider.theme.spacing.lg)
            .padding(.top, themeProvider.theme.spacing.md)
        }
        .refreshable {
            CadaEuroLogger.ui("Pull to refresh triggered", component: "ShoppingListView")
            await viewModel.refreshList()
        }
    }
    
    // MARK: - Toolbar Content
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .navigationBarTrailing) {
            // ✅ Componente MenuButton finalizado
            MenuButton { action in
                handleMenuAction(action)
            }
        }
        #else
        ToolbarItem(placement: .primaryAction) {
            // ✅ Componente MenuButton finalizado
            MenuButton { action in
                handleMenuAction(action)
            }
        }
        #endif
    }
    
    // MARK: - Sheet Views
    
    @ViewBuilder
    private var manualInputSheet: some View {
        NavigationStack {
            // ✅ Componente ManualInputForm finalizado - com suporte a dados do scanner e voz
            ManualInputForm(
                initialData: voiceProcessedData ?? scannedProductData,
                onAdd: { item in
                    CadaEuroLogger.ui("Item added via manual input", component: "ManualInputForm", metadata: [
                        "item_name": item.name,
                        "item_price": String(item.price),
                        "is_from_scanner": scannedProductData != nil ? "true" : "false",
                        "is_from_voice": voiceProcessedData != nil ? "true" : "false"
                    ])
                    let shoppingItem = ShoppingListItem(
                        name: item.name, 
                        price: item.price, 
                        captureMethod: item.captureMethod
                    )
                    viewModel.addItem(shoppingItem)
                    showingManualInput = false
                    scannedProductData = nil // Limpar dados do scanner
                    voiceProcessedData = nil // Limpar dados da voz
                },
                onCancel: {
                    CadaEuroLogger.ui("Manual input cancelled", component: "ManualInputForm")
                    showingManualInput = false
                    scannedProductData = nil // Limpar dados do scanner
                    voiceProcessedData = nil // Limpar dados da voz
                }
            )
            .navigationTitle("Adicionar Produto")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        showingManualInput = false
                    }
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        showingManualInput = false
                    }
                }
                #endif
            }
        }
    }
    
    @ViewBuilder
    private var scannerView: some View {
        // ✅ Componente ScannerOverlay finalizado - NOVO FLUXO
        ScannerOverlay(
            onItemScanned: { productData in
                CadaEuroLogger.ocr("Product scanned successfully", confidence: 0.85, metadata: [
                    "product_name": productData.name,
                    "price": String(productData.price)
                ])
                
                // Novo fluxo simplificado: usar ManualInputForm com dados pré-preenchidos
                scannedProductData = productData
                showingScanner = false
                showingManualInput = true
            },
            onCancel: {
                CadaEuroLogger.ui("Scanner cancelled", component: "ScannerOverlay")
                showingScanner = false
            },
            onFallbackToManual: {
                CadaEuroLogger.ui("Scanner fallback to manual", component: "ScannerOverlay")
                showingScanner = false
                showingManualInput = true
            }
        )
    }

    @ViewBuilder
    private var savedListsView: some View {
        // ✅ Componente SavedListsView implementado - Fase 3A Foundation
        SavedListsView()
    }
    
    @ViewBuilder
    private var statsView: some View {
        // ✅ Componente StatsView implementado - Fase 3A Foundation
        StatsView()
    }
    
    @ViewBuilder
    private var settingsView: some View {
        NavigationStack {
            // TODO: Implementar SettingsView na próxima iteração
            Text("Definições")
                .navigationTitle("Definições")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.large)
                #endif
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Fechar") {
                            showingSettings = false
                        }
                    }
                    #else
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Fechar") {
                            showingSettings = false
                        }
                    }
                    #endif
                }
        }
    }
    
    // MARK: - Action Handlers
    
    private func handleCaptureMethodSelection(_ method: CaptureMethod) {
        switch method {
        case .scanner:
            showingScanner = true
            
        case .voice:
            showingVoiceRecorder = true
            
        case .manual:
            showingManualInput = true
        }
    }
    
    private func handleMenuAction(_ action: MenuAction) {
        switch action {
        case .savedLists:
            showingSavedLists = true
            
        case .statistics:
            showingStats = true
            
        case .settings:
            showingSettings = true
        }
    }
    
    @ViewBuilder
    private var voiceRecorderOverlay: some View {
        VoiceRecorderOverlay(
            onTranscriptionComplete: { transcription in
                CadaEuroLogger.voice("Voice overlay transcription complete", transcription: transcription, metadata: [
                    "length": String(transcription.count),
                    "source": "overlay"
                ])
                
                // Processar transcrição com LLM
                Task {
                    await processVoiceTranscription(transcription)
                }
            },
            onCancel: {
                CadaEuroLogger.ui("Voice overlay cancelled", component: "VoiceRecorderOverlay")
                showingVoiceRecorder = false
                voiceProcessedData = nil
            },
            onError: { error in
                CadaEuroLogger.error("Voice overlay error", error: error, category: .voice)
                showingVoiceRecorder = false
                viewModel.handleError(error)
            },
            onFallbackToManual: {
                CadaEuroLogger.ui("Voice overlay fallback to manual", component: "VoiceRecorderOverlay")
                showingVoiceRecorder = false
                voiceProcessedData = nil
                showingManualInput = true
            }
        )
    }
    
    // MARK: - Voice Recorder Overlay Positioned
    
    @State private var captureButtonsFrame: CGRect = .zero
    
    @ViewBuilder
    private var voiceRecorderOverlayPositioned: some View {
        if !captureButtonsFrame.isEmpty {
            VoiceRecorderOverlay(
                onTranscriptionComplete: { transcription in
                    CadaEuroLogger.voice("Voice overlay transcription complete", transcription: transcription, metadata: [
                        "length": String(transcription.count),
                        "source": "overlay_positioned"
                    ])
                    
                    // Processar transcrição com LLM
                    Task {
                        await processVoiceTranscription(transcription)
                    }
                },
                onCancel: {
                    CadaEuroLogger.ui("Voice overlay cancelled", component: "VoiceRecorderOverlay")
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showingVoiceRecorder = false
                    }
                    voiceProcessedData = nil
                },
                onError: { error in
                    CadaEuroLogger.error("Voice overlay error", error: error, category: .voice)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showingVoiceRecorder = false
                    }
                    viewModel.handleError(error)
                },
                onFallbackToManual: {
                    CadaEuroLogger.ui("Voice overlay fallback to manual", component: "VoiceRecorderOverlay")
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showingVoiceRecorder = false
                    }
                    voiceProcessedData = nil
                    showingManualInput = true
                }
            )
            .position(
                x: captureButtonsFrame.midX,
                y: captureButtonsFrame.midY - 40
            )
            .zIndex(999) // Garantir que está acima de tudo
        }
    }

    // MARK: - Voice Processing
    
    @MainActor
    private func processVoiceTranscription(_ transcription: String) async {
        // Extrair produto e preço usando StringExtensions
        let (productName, extractedPrice) = transcription.extractProductAndPrice()
        
        guard !productName.isEmpty else {
            CadaEuroLogger.warning("Voice processing failed - empty product name", metadata: [
                "transcription": transcription
            ], category: .voice)
            
            // Fechar overlay e mostrar erro
            showingVoiceRecorder = false
            viewModel.handleError(VoiceInputError.unableToExtractProduct)
            return
        }
        
        let price = extractedPrice ?? 0.0
        
        // Validar dados usando CadaEuroValidator
        let validation = CadaEuroValidator.validateProduct(
            name: productName,
            price: price,
            captureMethod: .voice,
            confidence: transcription.textConfidenceScore
        )
        
        if validation.isValid {
            // Criar ProductData para pré-preenchimento do ManualInputForm
            voiceProcessedData = ProductData(
                name: productName.normalizedProductName,
                price: price,
                captureMethod: .voice
            )
            
            CadaEuroLogger.voice("Voice processing successful", transcription: transcription, metadata: [
                "extracted_product": productName,
                "extracted_price": String(price),
                "validation_status": "success"
            ])
            
            // Fechar overlay e abrir ManualInputForm com dados pré-preenchidos
            showingVoiceRecorder = false
            showingManualInput = true
        } else {
            CadaEuroLogger.validation("Voice input validation failed", isValid: false, field: "voice_transcription", metadata: [
                "errors": validation.errors.map { $0.localizedDescription }.joined(separator: ", "),
                "warnings": validation.warnings.joined(separator: ", ")
            ])
            
            // Fechar overlay e mostrar erro
            showingVoiceRecorder = false
            if let firstError = validation.errors.first {
                viewModel.handleError(firstError)
            } else {
                viewModel.handleError(VoiceInputError.lowConfidenceScore)
            }
        }
    }
}

// MARK: - Shopping List ViewModel

/// ViewModel para ShoppingListView com gestão de estado e business logic
@MainActor
public final class ShoppingListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var items: [ShoppingListItem] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    
    // MARK: - Computed Properties
    
    public var totalAmount: Double {
        items.reduce(0) { total, item in
            total + (item.price * Double(item.quantity))
        }.roundedToEuro
    }
    
    public var isEmpty: Bool {
        items.isEmpty
    }
    
    // MARK: - Item Management
    
    public func addItem(_ item: ShoppingListItem) {
        CadaEuroLogger.info("Adding item to list", metadata: [
            "item_name": item.name,
            "item_price": String(item.price),
            "capture_method": item.captureMethod.analyticsName,
            "current_items_count": String(items.count)
        ], category: .userInteraction)
        
        var transaction = Transaction(animation: .spring(response: 0.3, dampingFraction: 0.7))
        transaction.disablesAnimations = false
        withTransaction(transaction) {
            items.append(item)
        }   
        
        // TODO: Fase 5 - Persistir no SwiftData
        // await persistenceManager.save(item)
    }
    
    public func deleteItem(_ item: ShoppingListItem) {
        CadaEuroLogger.info("Deleting item from list", metadata: [
            "item_name": item.name,
            "remaining_items": String(items.count - 1)
        ], category: .userInteraction)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            items.removeAll { $0.id == item.id }
        }
        
        // TODO: Fase 5 - Remover do SwiftData
        // await persistenceManager.delete(item)
    }
    
    public func updateItem(_ item: ShoppingListItem) {
        CadaEuroLogger.info("Updating item in list", metadata: [
            "item_id": item.id.uuidString,
            "item_name": item.name
        ], category: .userInteraction)
        
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                items[index] = item
            }
        }
        
        // TODO: Fase 5 - Atualizar no SwiftData
        // await persistenceManager.update(item)
    }
    
    // MARK: - List Management
    
    public func saveCurrentList() {
        guard !items.isEmpty else { return }
        
        CadaEuroLogger.info("Saving current list", metadata: [
            "items_count": String(items.count),
            "total_amount": String(totalAmount)
        ], category: .userInteraction)
        
        // TODO: Fase 5 - Implementar salvamento real
        // let shoppingList = ShoppingList(items: items, total: totalAmount)
        // await persistenceManager.save(shoppingList)
        
        // Simular salvamento por agora
        startNewList()
    }
    
    public func startNewList() {
        CadaEuroLogger.info("Starting new list", metadata: [
            "previous_items_count": String(items.count)
        ], category: .userInteraction)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            items.removeAll()
        }
        
        // TODO: Fase 5 - Criar nova lista no SwiftData
        // await persistenceManager.createNewList()
    }
    
    // MARK: - Input Processing
    
    public func processVoiceInput(_ transcription: String) {
        CadaEuroLogger.voice("Processing voice input", transcription: transcription, metadata: [
            "transcription_length": String(transcription.count)
        ])
        
        // ✅ Usar StringExtensions.extractProductAndPrice()
        let (productName, extractedPrice) = transcription.extractProductAndPrice()
        
        guard !productName.isEmpty else {
            CadaEuroLogger.warning("Voice input processing failed", metadata: [
                "reason": "empty_product_name",
                "transcription": transcription
            ], category: .voice)
            
            handleError(VoiceInputError.unableToExtractProduct)
            return
        }
        
        let price = extractedPrice ?? 0.0
        let item = ShoppingListItem(name: productName, price: price, captureMethod: .voice)
        
        // ✅ Usar CadaEuroValidator para validação completa
        let validation = CadaEuroValidator.validateProduct(
            name: productName,
            price: price,
            captureMethod: .voice,
            confidence: transcription.textConfidenceScore
        )
        
        if validation.isValid {
            addItem(item)
        } else {
            CadaEuroLogger.validation("Voice input validation failed", isValid: false, field: "voice_transcription", metadata: [
                "errors": validation.errors.map { $0.localizedDescription }.joined(separator: ", "),
                "warnings": validation.warnings.joined(separator: ", ")
            ])
            
            // Mostrar primeiro erro
            if let firstError = validation.errors.first {
                handleError(firstError)
            }
        }
    }
    
    // MARK: - Error Handling
    
    public func handleError(_ error: Error) {
        CadaEuroLogger.error("ShoppingListView error occurred", error: error, category: .error)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            errorMessage = error.localizedDescription
        }
        
        // Clear error after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.errorMessage = nil
            }
        }
    }
    
    // MARK: - Refresh
    
    public func refreshList() async {
        CadaEuroLogger.info("Refreshing shopping list", category: .userInteraction)
        
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Fase 5 - Implementar refresh real
        // await persistenceManager.refresh()
        
        // Simular delay de network
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }
}

// MARK: - Supporting Types

/// Errors específicos de entrada de voz
enum VoiceInputError: LocalizedError {
    case unableToExtractProduct
    case lowConfidenceScore
    case processingTimeout
    
    var errorDescription: String? {
        switch self {
        case .unableToExtractProduct:
            "Não foi possível identificar o produto na gravação"
        case .lowConfidenceScore:
            "Gravação não está clara. Tente novamente"
        case .processingTimeout:
            "Tempo limite de processamento excedido"
        }
    }
}

/// Item de lista de compras específico para ShoppingListView
public struct ShoppingListItem: Identifiable, Hashable, Sendable {
    public let id = UUID()
    public let name: String
    public let price: Double
    public let quantity: Int
    public let captureMethod: CaptureMethod
    public let dateAdded: Date
    
    public init(name: String, price: Double, quantity: Int = 1, captureMethod: CaptureMethod) {
        self.name = name
        self.price = price
        self.quantity = quantity
        self.captureMethod = captureMethod
        self.dateAdded = Date()
    }
}

// MARK: - Previews

#Preview("Shopping List - Empty") {
    ShoppingListView()
        .themeProvider(.preview)
}

#Preview("Shopping List - With Items") {
    let view = ShoppingListView()
    view.internalViewModel.items = [
        ShoppingListItem(name: "Leite Mimosa", price: 1.29, captureMethod: .scanner),
        ShoppingListItem(name: "Pão de Forma", price: 2.50, captureMethod: .voice),
        ShoppingListItem(name: "Ovos", price: 3.99, captureMethod: .manual)
    ]
    return view.themeProvider(.preview)
}

#Preview("Shopping List - Dark Mode") {
    let view = ShoppingListView()
    view.internalViewModel.items = [
        ShoppingListItem(name: "Leite", price: 1.29, captureMethod: .scanner),
        ShoppingListItem(name: "Açúcar", price: 2.85, captureMethod: .voice)
    ]
    return view.themeProvider(.darkPreview)
        .preferredColorScheme(.dark)
}

#Preview("Shopping List - Loading State") {
    let view = ShoppingListView()
    view.internalViewModel.isLoading = true
    return view.themeProvider(.preview)
}
