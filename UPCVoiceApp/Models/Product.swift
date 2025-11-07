//
//  Product.swift
//  UPCVoiceApp
//
//  Data model for product information from UPC lookup
//

import Foundation

struct Product: Codable, Identifiable {
    let id: UUID
    let upc: String
    let title: String
    let description: String?
    let brand: String?
    let category: String?
    let imageURL: String?
    let price: Double?
    let currency: String?

    init(upc: String, title: String, description: String? = nil, brand: String? = nil,
         category: String? = nil, imageURL: String? = nil, price: Double? = nil, currency: String? = nil) {
        self.id = UUID()
        self.upc = upc
        self.title = title
        self.description = description
        self.brand = brand
        self.category = category
        self.imageURL = imageURL
        self.price = price
        self.currency = currency
    }
}

// Response model for UPC Database API
struct UPCItemDBResponse: Codable {
    let code: String
    let total: Int
    let items: [UPCItem]?
}

struct UPCItem: Codable {
    let ean: String
    let title: String
    let description: String?
    let brand: String?
    let category: String?
    let images: [String]?
    let lowestRecordedPrice: Double?
    let highestRecordedPrice: Double?

    enum CodingKeys: String, CodingKey {
        case ean, title, description, brand, category, images
        case lowestRecordedPrice = "lowest_recorded_price"
        case highestRecordedPrice = "highest_recorded_price"
    }

    func toProduct() -> Product {
        return Product(
            upc: ean,
            title: title,
            description: description,
            brand: brand,
            category: category,
            imageURL: images?.first,
            price: lowestRecordedPrice,
            currency: "USD"
        )
    }
}
