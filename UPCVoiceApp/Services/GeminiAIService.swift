//
//  GeminiAIService.swift
//  UPCVoiceApp
//
//  Service for Google Gemini AI API integration
//

import Foundation

class GeminiAIService: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent"

    @Published var lastResponse: String = ""
    @Published var isProcessing: Bool = false

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // Generate AI response for voice commands
    func processVoiceCommand(_ command: String, context: AIContext) async throws -> AIResponse {
        isProcessing = true
        defer { isProcessing = false }

        let prompt = buildPrompt(command: command, context: context)
        let response = try await generateContent(prompt: prompt)

        return parseAIResponse(response)
    }

    // Analyze product and provide insights
    func analyzeProduct(_ product: Product) async throws -> String {
        let prompt = """
        Analyze this product and provide helpful insights:
        Product: \(product.title)
        Brand: \(product.brand ?? "Unknown")
        Category: \(product.category ?? "Unknown")
        Description: \(product.description ?? "No description")

        Provide a brief summary (2-3 sentences) about this product, including any notable features or considerations.
        """

        return try await generateContent(prompt: prompt)
    }

    // Generate inventory suggestions
    func getInventorySuggestion(for item: InventoryItem) async throws -> String {
        let prompt = """
        For inventory management, analyze this item:
        Product: \(item.product.title)
        Current Quantity: \(item.quantity)
        Location: \(item.location ?? "Not specified")

        Provide a brief recommendation about stock levels or organization (1-2 sentences).
        """

        return try await generateContent(prompt: prompt)
    }

    // Main API call to Gemini
    private func generateContent(prompt: String) async throws -> String {
        let urlString = "\(baseURL)?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw GeminiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = GeminiRequest(
            contents: [Content(parts: [Part(text: prompt)])]
        )

        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw GeminiError.requestFailed
        }

        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)

        guard let text = geminiResponse.candidates?.first?.content.parts.first?.text else {
            throw GeminiError.noResponseText
        }

        DispatchQueue.main.async {
            self.lastResponse = text
        }

        return text
    }

    private func buildPrompt(command: String, context: AIContext) -> String {
        var prompt = """
        You are an AI assistant for a UPC product lookup and inventory management app.
        User voice command: "\(command)"

        """

        if let currentProduct = context.currentProduct {
            prompt += """
            Current product in view:
            - Name: \(currentProduct.title)
            - UPC: \(currentProduct.upc)
            - Brand: \(currentProduct.brand ?? "Unknown")

            """
        }

        if context.inventoryCount > 0 {
            prompt += "Total items in inventory: \(context.inventoryCount)\n\n"
        }

        prompt += """
        Based on the command, provide a concise, helpful response.
        If the command is about adding to inventory, confirm the action.
        If asking about product details, provide relevant information.
        Keep responses brief and actionable (2-3 sentences max).
        """

        return prompt
    }

    private func parseAIResponse(_ text: String) -> AIResponse {
        // Parse the AI response to determine intent and action
        let lowercased = text.lowercased()

        if lowercased.contains("add") && lowercased.contains("inventory") {
            return AIResponse(text: text, action: .addToInventory)
        } else if lowercased.contains("remove") || lowercased.contains("delete") {
            return AIResponse(text: text, action: .removeFromInventory)
        } else if lowercased.contains("update") || lowercased.contains("change") {
            return AIResponse(text: text, action: .updateInventory)
        } else if lowercased.contains("search") || lowercased.contains("find") {
            return AIResponse(text: text, action: .searchProduct)
        } else {
            return AIResponse(text: text, action: .info)
        }
    }
}

// MARK: - Data Models

struct GeminiRequest: Codable {
    let contents: [Content]
}

struct Content: Codable {
    let parts: [Part]
}

struct Part: Codable {
    let text: String
}

struct GeminiResponse: Codable {
    let candidates: [Candidate]?
}

struct Candidate: Codable {
    let content: Content
}

struct AIContext {
    let currentProduct: Product?
    let inventoryCount: Int
    let recentUPCs: [String]

    init(currentProduct: Product? = nil, inventoryCount: Int = 0, recentUPCs: [String] = []) {
        self.currentProduct = currentProduct
        self.inventoryCount = inventoryCount
        self.recentUPCs = recentUPCs
    }
}

struct AIResponse {
    let text: String
    let action: AIAction

    enum AIAction {
        case addToInventory
        case removeFromInventory
        case updateInventory
        case searchProduct
        case info
    }
}

enum GeminiError: Error {
    case invalidURL
    case requestFailed
    case noResponseText
}
