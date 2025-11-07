//
//  UPCLookupService.swift
//  UPCVoiceApp
//
//  Service for looking up product information by UPC code
//

import Foundation

class UPCLookupService: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var lastError: String?

    // Using UPCitemdb.com API (free tier available)
    private let baseURL = "https://api.upcitemdb.com/prod/trial/lookup"

    // Alternative APIs (uncomment to use):
    // private let baseURL = "https://api.barcodelookup.com/v3/products"
    // private let baseURL = "https://api.upcdatabase.org/product"

    func lookupProduct(upc: String) async throws -> Product {
        isLoading = true
        lastError = nil

        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }

        // Validate UPC
        guard isValidUPC(upc) else {
            throw UPCError.invalidFormat
        }

        let product = try await fetchFromUPCItemDB(upc: upc)
        return product
    }

    // MARK: - UPCitemdb.com API
    private func fetchFromUPCItemDB(upc: String) async throws -> Product {
        let urlString = "\(baseURL)?upc=\(upc)"
        guard let url = URL(string: urlString) else {
            throw UPCError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw UPCError.requestFailed
        }

        // Handle different response codes
        switch httpResponse.statusCode {
        case 200:
            let upcResponse = try JSONDecoder().decode(UPCItemDBResponse.self, from: data)
            guard let item = upcResponse.items?.first else {
                throw UPCError.productNotFound
            }
            return item.toProduct()

        case 404:
            throw UPCError.productNotFound

        case 429:
            throw UPCError.rateLimitExceeded

        default:
            throw UPCError.requestFailed
        }
    }

    // MARK: - Manual Product Entry (fallback)
    func createManualProduct(upc: String, title: String, brand: String? = nil) -> Product {
        return Product(
            upc: upc,
            title: title,
            description: "Manually entered product",
            brand: brand,
            category: nil,
            imageURL: nil,
            price: nil,
            currency: nil
        )
    }

    // MARK: - UPC Validation
    private func isValidUPC(_ upc: String) -> Bool {
        // Check if UPC contains only digits
        let digits = CharacterSet.decimalDigits
        guard upc.unicodeScalars.allSatisfy({ digits.contains($0) }) else {
            return false
        }

        // Check length (UPC-A: 12 digits, UPC-E: 8 digits, EAN-13: 13 digits)
        let validLengths = [8, 12, 13]
        guard validLengths.contains(upc.count) else {
            return false
        }

        // Validate check digit for UPC-A (12 digits)
        if upc.count == 12 {
            return validateUPCACheckDigit(upc)
        }

        return true
    }

    private func validateUPCACheckDigit(_ upc: String) -> Bool {
        let digits = upc.compactMap { Int(String($0)) }
        guard digits.count == 12 else { return false }

        // Calculate check digit
        let oddSum = digits[0] + digits[2] + digits[4] + digits[6] + digits[8] + digits[10]
        let evenSum = digits[1] + digits[3] + digits[5] + digits[7] + digits[9]
        let total = (oddSum * 3) + evenSum
        let checkDigit = (10 - (total % 10)) % 10

        return checkDigit == digits[11]
    }

    // MARK: - Barcode Scanner Integration
    func formatBarcodeForLookup(_ barcode: String) -> String {
        // Remove any non-numeric characters
        let cleaned = barcode.filter { $0.isNumber }

        // Handle EAN-13 to UPC-A conversion if needed
        if cleaned.count == 13 && cleaned.hasPrefix("0") {
            return String(cleaned.dropFirst())
        }

        return cleaned
    }
}

enum UPCError: Error, LocalizedError {
    case invalidFormat
    case invalidURL
    case requestFailed
    case productNotFound
    case rateLimitExceeded
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "Invalid UPC format. Please enter 8 or 12 digits."
        case .invalidURL:
            return "Invalid API URL configuration."
        case .requestFailed:
            return "Failed to lookup product. Please try again."
        case .productNotFound:
            return "Product not found in database. You can add it manually."
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again in a few minutes."
        case .networkError:
            return "Network error. Please check your connection."
        }
    }
}
