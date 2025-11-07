//
//  InventoryManager.swift
//  UPCVoiceApp
//
//  Service for managing inventory items with persistence
//

import Foundation
import Combine

class InventoryManager: ObservableObject {
    @Published var items: [InventoryItem] = []
    @Published var searchResults: [InventoryItem] = []

    private let defaults = UserDefaults.standard
    private let itemsKey = "inventory_items"

    init() {
        loadInventory()
    }

    // MARK: - CRUD Operations

    func addItem(_ product: Product, quantity: Int, location: String? = nil, notes: String? = nil) {
        // Check if product already exists
        if let existingIndex = items.firstIndex(where: { $0.product.upc == product.upc }) {
            // Update existing item quantity
            items[existingIndex].adjustQuantity(by: quantity)
        } else {
            // Create new inventory item
            let newItem = InventoryItem(
                product: product,
                quantity: quantity,
                location: location,
                notes: notes
            )
            items.append(newItem)
        }

        saveInventory()
    }

    func removeItem(_ item: InventoryItem) {
        items.removeAll { $0.id == item.id }
        saveInventory()
    }

    func updateItemQuantity(_ item: InventoryItem, newQuantity: Int) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].updateQuantity(newQuantity)
            saveInventory()
        }
    }

    func adjustItemQuantity(_ item: InventoryItem, by amount: Int) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].adjustQuantity(by: amount)
            saveInventory()
        }
    }

    func updateItemLocation(_ item: InventoryItem, location: String) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].location = location
            items[index].lastUpdated = Date()
            saveInventory()
        }
    }

    func updateItemNotes(_ item: InventoryItem, notes: String) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].notes = notes
            items[index].lastUpdated = Date()
            saveInventory()
        }
    }

    // MARK: - Search & Filter

    func searchByUPC(_ upc: String) -> InventoryItem? {
        return items.first { $0.product.upc == upc }
    }

    func searchByName(_ query: String) -> [InventoryItem] {
        let lowercased = query.lowercased()
        return items.filter {
            $0.product.title.lowercased().contains(lowercased) ||
            $0.product.brand?.lowercased().contains(lowercased) ?? false
        }
    }

    func filterByCategory(_ category: String) -> [InventoryItem] {
        return items.filter { $0.product.category?.lowercased() == category.lowercased() }
    }

    func filterByLocation(_ location: String) -> [InventoryItem] {
        return items.filter { $0.location?.lowercased() == location.lowercased() }
    }

    func getLowStockItems(threshold: Int = 5) -> [InventoryItem] {
        return items.filter { $0.quantity <= threshold }
    }

    // MARK: - Statistics

    func getTotalItems() -> Int {
        return items.count
    }

    func getTotalQuantity() -> Int {
        return items.reduce(0) { $0 + $1.quantity }
    }

    func getCategories() -> [String] {
        let categories = items.compactMap { $0.product.category }
        return Array(Set(categories)).sorted()
    }

    func getLocations() -> [String] {
        let locations = items.compactMap { $0.location }
        return Array(Set(locations)).sorted()
    }

    func getItemsByCategory() -> [String: [InventoryItem]] {
        Dictionary(grouping: items) { $0.product.category ?? "Uncategorized" }
    }

    // MARK: - Bulk Operations

    func exportToCSV() -> String {
        var csv = "UPC,Product Name,Brand,Category,Quantity,Location,Notes,Date Added\n"

        for item in items {
            let row = [
                item.product.upc,
                item.product.title,
                item.product.brand ?? "",
                item.product.category ?? "",
                String(item.quantity),
                item.location ?? "",
                item.notes ?? "",
                formatDate(item.dateAdded)
            ].joined(separator: ",")

            csv += row + "\n"
        }

        return csv
    }

    func clearAllItems() {
        items.removeAll()
        saveInventory()
    }

    // MARK: - Persistence

    private func saveInventory() {
        if let encoded = try? JSONEncoder().encode(items) {
            defaults.set(encoded, forKey: itemsKey)
        }
    }

    private func loadInventory() {
        if let data = defaults.data(forKey: itemsKey),
           let decoded = try? JSONDecoder().decode([InventoryItem].self, from: data) {
            items = decoded
        }
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    // Voice command helpers
    func interpretQuantityCommand(_ command: String) -> Int? {
        let words = command.lowercased().components(separatedBy: " ")

        for (index, word) in words.enumerated() {
            if let number = Int(word) {
                return number
            }

            // Handle word numbers
            let wordNumbers = [
                "one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
                "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10,
                "twenty": 20, "thirty": 30, "forty": 40, "fifty": 50
            ]

            if let number = wordNumbers[word] {
                return number
            }
        }

        return nil
    }
}
