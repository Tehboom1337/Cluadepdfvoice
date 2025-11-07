//
//  MainViewModel.swift
//  UPCVoiceApp
//
//  Main ViewModel coordinating all services
//

import Foundation
import SwiftUI
import Combine

@MainActor
class MainViewModel: ObservableObject {
    // Services
    let voiceService = VoiceRecognitionService()
    let upcLookupService = UPCLookupService()
    let inventoryManager = InventoryManager()
    var geminiService: GeminiAIService?

    // Published state
    @Published var currentProduct: Product?
    @Published var isProcessing: Bool = false
    @Published var statusMessage: String = "Ready"
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var aiResponse: String = ""

    // Settings
    @Published var geminiAPIKey: String = ""

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
        loadSettings()
    }

    private func setupBindings() {
        // Monitor voice recognition
        voiceService.$recognizedText
            .sink { [weak self] text in
                if !text.isEmpty {
                    self?.statusMessage = "Recognized: \(text)"
                }
            }
            .store(in: &cancellables)
    }

    private func loadSettings() {
        if let apiKey = UserDefaults.standard.string(forKey: "gemini_api_key") {
            geminiAPIKey = apiKey
            geminiService = GeminiAIService(apiKey: apiKey)
        }
    }

    func saveAPIKey(_ key: String) {
        geminiAPIKey = key
        UserDefaults.standard.set(key, forKey: "gemini_api_key")
        geminiService = GeminiAIService(apiKey: key)
    }

    // MARK: - Voice Commands

    func startVoiceRecording() {
        do {
            try voiceService.startRecording()
            statusMessage = "Listening..."
        } catch {
            showErrorAlert("Failed to start recording: \(error.localizedDescription)")
        }
    }

    func stopVoiceRecording() {
        voiceService.stopRecording()
        processVoiceCommand(voiceService.recognizedText)
    }

    private func processVoiceCommand(_ command: String) {
        Task {
            isProcessing = true
            statusMessage = "Processing command..."

            // Try to extract UPC from command
            if let upc = voiceService.extractUPC(from: command) {
                await lookupUPC(upc)
            } else if let gemini = geminiService {
                // Use Gemini to interpret the command
                do {
                    let context = AIContext(
                        currentProduct: currentProduct,
                        inventoryCount: inventoryManager.getTotalItems(),
                        recentUPCs: []
                    )

                    let response = try await gemini.processVoiceCommand(command, context: context)
                    aiResponse = response.text
                    statusMessage = "AI: \(response.text)"

                    // Handle the action
                    await handleAIAction(response.action)
                } catch {
                    showErrorAlert("AI processing failed: \(error.localizedDescription)")
                }
            } else {
                showErrorAlert("Could not interpret command. Please speak a UPC code or configure Gemini API.")
            }

            isProcessing = false
        }
    }

    private func handleAIAction(_ action: AIResponse.AIAction) async {
        switch action {
        case .addToInventory:
            if let product = currentProduct {
                addToInventory(product: product, quantity: 1)
            }
        case .searchProduct:
            // Trigger search view
            break
        default:
            break
        }
    }

    // MARK: - UPC Lookup

    func lookupUPC(_ upc: String) async {
        isProcessing = true
        statusMessage = "Looking up UPC: \(upc)"

        do {
            let product = try await upcLookupService.lookupProduct(upc: upc)
            currentProduct = product
            statusMessage = "Found: \(product.title)"

            // Get AI insights if available
            if let gemini = geminiService {
                let insights = try? await gemini.analyzeProduct(product)
                if let insights = insights {
                    aiResponse = insights
                }
            }
        } catch {
            showErrorAlert(error.localizedDescription)
        }

        isProcessing = false
    }

    func manualUPCEntry(_ upc: String) {
        Task {
            await lookupUPC(upc)
        }
    }

    // MARK: - Inventory Management

    func addToInventory(product: Product, quantity: Int, location: String? = nil, notes: String? = nil) {
        inventoryManager.addItem(product, quantity: quantity, location: location, notes: notes)
        statusMessage = "Added \(product.title) to inventory"
    }

    func removeFromInventory(_ item: InventoryItem) {
        inventoryManager.removeItem(item)
        statusMessage = "Removed item from inventory"
    }

    func updateQuantity(_ item: InventoryItem, newQuantity: Int) {
        inventoryManager.updateItemQuantity(item, newQuantity: newQuantity)
        statusMessage = "Updated quantity"
    }

    func adjustQuantity(_ item: InventoryItem, by amount: Int) {
        inventoryManager.adjustItemQuantity(item, by: amount)
    }

    // MARK: - Error Handling

    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
        statusMessage = "Error occurred"
    }
}
