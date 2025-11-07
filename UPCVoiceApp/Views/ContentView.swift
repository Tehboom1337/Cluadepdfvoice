//
//  ContentView.swift
//  UPCVoiceApp
//
//  Main app interface
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @State private var selectedTab = 0
    @State private var manualUPC = ""

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab - Voice Input & Product Lookup
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            // Inventory Tab
            InventoryListView()
                .tabItem {
                    Label("Inventory", systemImage: "list.bullet.rectangle")
                }
                .tag(1)

            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @State private var showManualEntry = false
    @State private var manualUPC = ""
    @State private var showProductDetail = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Status Card
                    StatusCard(
                        message: viewModel.statusMessage,
                        isProcessing: viewModel.isProcessing
                    )

                    // Voice Recording Button
                    VoiceRecordButton(
                        isRecording: viewModel.voiceService.isRecording,
                        onStart: { viewModel.startVoiceRecording() },
                        onStop: { viewModel.stopVoiceRecording() }
                    )

                    // Manual UPC Entry
                    VStack(spacing: 12) {
                        Text("Or enter UPC manually:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack {
                            TextField("Enter UPC", text: $manualUPC)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)

                            Button(action: {
                                viewModel.manualUPCEntry(manualUPC)
                                manualUPC = ""
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .padding(12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                            .disabled(manualUPC.isEmpty)
                        }
                        .padding(.horizontal)
                    }

                    // Current Product Display
                    if let product = viewModel.currentProduct {
                        ProductCard(product: product)
                            .onTapGesture {
                                showProductDetail = true
                            }
                    }

                    // AI Response
                    if !viewModel.aiResponse.isEmpty {
                        AIResponseCard(response: viewModel.aiResponse)
                    }

                    // Quick Stats
                    QuickStatsView()

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("UPC Voice Lookup")
            .sheet(isPresented: $showProductDetail) {
                if let product = viewModel.currentProduct {
                    ProductDetailView(product: product)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct StatusCard: View {
    let message: String
    let isProcessing: Bool

    var body: some View {
        HStack {
            if isProcessing {
                ProgressView()
                    .padding(.trailing, 8)
            }

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct VoiceRecordButton: View {
    let isRecording: Bool
    let onStart: () -> Void
    let onStop: () -> Void

    var body: some View {
        Button(action: {
            if isRecording {
                onStop()
            } else {
                onStart()
            }
        }) {
            VStack(spacing: 12) {
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(isRecording ? .red : .blue)

                Text(isRecording ? "Tap to Stop" : "Tap to Speak")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.title)
                        .font(.headline)

                    if let brand = product.brand {
                        Text(brand)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Text("UPC: \(product.upc)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let imageURL = product.imageURL,
                   let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                }
            }

            if let price = product.price {
                Text("$\(String(format: "%.2f", price))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct AIResponseCard: View {
    let response: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("AI Assistant")
                    .font(.headline)
                    .foregroundColor(.purple)
            }

            Text(response)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(12)
    }
}

struct QuickStatsView: View {
    @EnvironmentObject var viewModel: MainViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Inventory Stats")
                .font(.headline)

            HStack(spacing: 20) {
                StatItem(
                    title: "Total Items",
                    value: "\(viewModel.inventoryManager.getTotalItems())",
                    icon: "cube.box"
                )

                StatItem(
                    title: "Total Quantity",
                    value: "\(viewModel.inventoryManager.getTotalQuantity())",
                    icon: "number"
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
