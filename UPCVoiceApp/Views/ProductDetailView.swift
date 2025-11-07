//
//  ProductDetailView.swift
//  UPCVoiceApp
//
//  Detailed product view with inventory actions
//

import SwiftUI

struct ProductDetailView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @Environment(\.dismiss) var dismiss

    let product: Product

    @State private var quantity: Int = 1
    @State private var location: String = ""
    @State private var notes: String = ""
    @State private var showAddSuccess = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Product Image
                    if let imageURL = product.imageURL,
                       let url = URL(string: imageURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Image(systemName: "photo")
                                .font(.system(size: 100))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }

                    // Product Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text(product.title)
                            .font(.title2)
                            .fontWeight(.bold)

                        if let brand = product.brand {
                            Label(brand, systemImage: "tag")
                                .foregroundColor(.secondary)
                        }

                        if let category = product.category {
                            Label(category, systemImage: "folder")
                                .foregroundColor(.secondary)
                        }

                        Divider()

                        Text("UPC: \(product.upc)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if let description = product.description {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.primary)
                        }

                        if let price = product.price {
                            Text("$\(String(format: "%.2f", price))")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal)

                    Divider()

                    // Add to Inventory Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Add to Inventory")
                            .font(.headline)

                        // Quantity
                        HStack {
                            Text("Quantity:")
                                .frame(width: 80, alignment: .leading)

                            Stepper(value: $quantity, in: 1...9999) {
                                Text("\(quantity)")
                                    .font(.headline)
                            }
                        }

                        // Location
                        HStack {
                            Text("Location:")
                                .frame(width: 80, alignment: .leading)

                            TextField("Optional", text: $location)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        // Notes
                        VStack(alignment: .leading) {
                            Text("Notes:")
                            TextEditor(text: $notes)
                                .frame(height: 80)
                                .border(Color.gray.opacity(0.3))
                        }

                        // Add Button
                        Button(action: addToInventory) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add to Inventory")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Product Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Added to Inventory", isPresented: $showAddSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("\(product.title) has been added to your inventory.")
            }
        }
    }

    private func addToInventory() {
        viewModel.addToInventory(
            product: product,
            quantity: quantity,
            location: location.isEmpty ? nil : location,
            notes: notes.isEmpty ? nil : notes
        )
        showAddSuccess = true
    }
}
