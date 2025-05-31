# 📱 CadaEuro

Aplicação premium de lista de compras para iOS 17+ que ajuda consumidores a controlar em tempo real o total das compras de supermercado. Combina tecnologia avançada (OCR, reconhecimento de voz, LLM) com design elegante inspirado na Apple Store.

![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![SwiftUI](https://img.shields.io/badge/Framework-SwiftUI-purple)
![License](https://img.shields.io/badge/License-Proprietary-red)

## 🎯 Visão Geral

CadaEuro é uma aplicação sofisticada que permite aos utilizadores:

- Controlar em tempo real o total das compras de supermercado
- Capturar produtos através de OCR, reconhecimento de voz ou entrada manual
- Gerir e organizar listas de compras com persistência via SwiftData
- Analisar gastos através de estatísticas detalhadas
- Desfrutar de uma experiência premium com design inspirado na Apple Store

## ✨ Funcionalidades Principais

### 🎥 Scanner OCR
- Reconhecimento ótico de caracteres para capturar etiquetas de preços
- Processamento on-device < 300ms por item
- Normalização de texto via LLM (GPT-4.1 mini / Gemini 2 Flash)

### 🎤 Entrada por Voz
- Reconhecimento de fala em português (Locale pt-PT)
- Transcrição streaming em tempo real
- Processamento LLM para normalização de texto

### 📋 Gestão de Listas
- Armazenamento local via SwiftData
- Sincronização entre dispositivos via CloudKit
- Interface intuitiva para edição e organização

### 📊 Estatísticas
- Análise de gastos por período
- Métricas calculadas: total gasto, média por lista, número de listas
- Visualização temporal com navegação intuitiva

### ⚙️ Personalização
- Suporte completo a light/dark mode
- Opções de acessibilidade avançadas
- Configurações de aparência e preferências

## 🏗️ Arquitetura

O CadaEuro segue os princípios de Clean Architecture com separação clara de responsabilidades:

- **Presentation**: Vistas SwiftUI, temas, design system
- **Domain**: Casos de uso (AddItem, ComputeTotal)
- **Data**: Repositórios (ItemRepository, SettingsRepository)

## 🎨 Design System

A aplicação adota uma estética Apple Store minimalista com:

- Cores adaptativas com suporte completo light/dark mode
- Tipografia San Francisco com pesos consistentes
- Microinterações premium com feedback háptico
- Conformidade total às diretrizes WCAG 2.1 AA e Human Interface Guidelines

## 🧪 Testes

O projeto implementa uma estratégia de testes abrangente:

- **Testes Unitários**: XCTest, Quick/Nimble com cobertura ≥ 80%
- **Testes de Snapshot**: iOSSnapshotTestCase para regressão UI
- **Testes de UI**: XCUITest + Fastlane para fluxos principais
- **Testes de Integração**: MockServer (Swift) para repositórios ↔ LLM

## 📦 Requisitos

- iOS 17.0 ou superior
- Xcode 15.0 ou superior
- Swift 6 ou superior

## 🚀 Instalação

1. Clone o repositório
2. Abra o ficheiro `CadaEuro.xcodeproj` no Xcode
3. Selecione o dispositivo ou simulador de destino
4. Execute o projeto (⌘+R)

## 📄 Licença

CadaEuro é uma aplicação proprietária. Todos os direitos reservados.
