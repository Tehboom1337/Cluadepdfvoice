//
//  InventoryListView.swift
//  UPCVoiceApp
//
//  List and manage inventory items
//

import SwiftUI

struct InventoryListView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @State private var searchText = ""
    @State private var showExportSheet = false
    @State private var selectedItem: InventoryItem?
    @State private var showDeleteAlert = false

    var filteredItems: [InventoryItem] {
        if searchText.isEmpty {
            return viewModel.inventoryManager.items
        } else {
            return viewModel.inventoryManager.searchByName(searchText)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.inventoryManager.items.isEmpty {
                    EmptyInventoryView()
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            InventoryRow(item: item)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        selectedItem = item
                                        showDeleteAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        viewModel.adjustQuantity(item, by: 1)
                                    } label: {
                                        Label("Add", systemImage: "plus")
                                    }
                                    .tint(.green)

                                    Button {
                                        viewModel.adjustQuantity(item, by: -1)
                                    } label: {
                                        Label("Remove", systemImage: "minus")
                                    }
                                    .tint(.orange)
                                }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search inventory")
                }
            }
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showExportSheet = true }) {
                            Label("Export CSV", systemImage: "square.and.arrow.up")
                        }

                        Button(role: .destructive, action: clearInventory) {
                            Label("Clear All", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showExportSheet) {
                ExportView()
            }
            .alert("Delete Item", isPresented: $showDeleteAlert, presenting: selectedItem) { item in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.removeFromInventory(item)
                }
            } message: { item in
                Text("Are you sure you want to delete \(item.product.title)?")
            }
        }
    }

    private func clearInventory() {
        viewModel.inventoryManager.clearAllItems()
    }
}

struct InventoryRow: View {
    @EnvironmentObject var viewModel: MainViewModel
    let item: InventoryItem

    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            if let imageURL = item.product.imageURL,
               let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "cube.box.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 50, height: 50)
            }

            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.title)
                    .font(.headline)
                    .lineLimit(2)

                if let brand = item.product.brand {
                    Text(brand)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let location = item.location {
                    Label(location, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Quantity Badge
            VStack(spacing: 4) {
                Text("\(item.quantity)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(quantityColor(item.quantity))

                Text("qty")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 60)
        }
        .padding(.vertical, 4)
    }

    private func quantityColor(_ quantity: Int) -> Color {
        if quantity <= 5 {
            return .red
        } else if quantity <= 10 {
            return .orange
        } else {
            return .green
        }
    }
}

struct EmptyInventoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            Text("No Items in Inventory")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Use voice commands or scan UPCs to add products to your inventory")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }
}

struct ExportView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "arrow.down.doc")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Export Inventory")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Export your inventory as a CSV file that can be opened in Excel or Numbers.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(action: exportCSV) {
                    Text("Export CSV")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func exportCSV() {
        let csv = viewModel.inventoryManager.exportToCSV()

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("inventory.csv")

        do {
            try csv.write(to: tempURL, atomically: true, encoding: .utf8)

            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityVC, animated: true)
            }
        } catch {
            print("Error exporting CSV: \(error)")
        }
    }
}
