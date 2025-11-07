//
//  InventoryItem.swift
//  UPCVoiceApp
//
//  Data model for inventory management
//

import Foundation

struct InventoryItem: Codable, Identifiable {
    let id: UUID
    let product: Product
    var quantity: Int
    var location: String?
    var notes: String?
    let dateAdded: Date
    var lastUpdated: Date

    init(product: Product, quantity: Int, location: String? = nil, notes: String? = nil) {
        self.id = UUID()
        self.product = product
        self.quantity = quantity
        self.location = location
        self.notes = notes
        self.dateAdded = Date()
        self.lastUpdated = Date()
    }

    mutating func updateQuantity(_ newQuantity: Int) {
        self.quantity = newQuantity
        self.lastUpdated = Date()
    }

    mutating func adjustQuantity(by amount: Int) {
        self.quantity += amount
        self.lastUpdated = Date()
    }
}
