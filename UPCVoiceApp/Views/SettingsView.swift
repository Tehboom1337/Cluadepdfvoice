//
//  SettingsView.swift
//  UPCVoiceApp
//
//  App settings and configuration
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @State private var apiKey: String = ""
    @State private var showAPIKeyInfo = false
    @State private var showSaveSuccess = false

    var body: some View {
        NavigationView {
            Form {
                // Google Gemini API Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Google Gemini API Key")
                                .font(.headline)

                            Spacer()

                            Button(action: { showAPIKeyInfo.toggle() }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                        }

                        SecureField("Enter API Key", text: $apiKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        if !viewModel.geminiAPIKey.isEmpty {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("API Key Configured")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }

                        Button(action: saveAPIKey) {
                            Text("Save API Key")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(apiKey.isEmpty ? Color.gray : Color.blue)
                                .cornerRadius(8)
                        }
                        .disabled(apiKey.isEmpty)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("AI Configuration")
                } footer: {
                    Text("Required for AI-powered voice commands and product insights.")
                }

                // Voice Recognition Section
                Section {
                    HStack {
                        Text("Speech Recognition")
                        Spacer()
                        Image(systemName: statusIcon)
                            .foregroundColor(statusColor)
                    }

                    Button(action: requestMicrophonePermission) {
                        Text("Request Microphone Permission")
                    }
                } header: {
                    Text("Permissions")
                } footer: {
                    Text("Microphone access is required for voice commands.")
                }

                // App Info Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Total Inventory Items")
                        Spacer()
                        Text("\(viewModel.inventoryManager.getTotalItems())")
                            .foregroundColor(.secondary)
                    }

                    Button(action: clearCache) {
                        Text("Clear Cache")
                            .foregroundColor(.red)
                    }
                } header: {
                    Text("About")
                }

                // Help Section
                Section {
                    Link(destination: URL(string: "https://ai.google.dev/")!) {
                        HStack {
                            Text("Get Google Gemini API Key")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                    }

                    Link(destination: URL(string: "https://www.upcitemdb.com/")!) {
                        HStack {
                            Text("UPC Database API")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                    }

                    Button(action: { showAPIKeyInfo = true }) {
                        HStack {
                            Text("How to Use Voice Commands")
                            Spacer()
                            Image(systemName: "questionmark.circle")
                        }
                    }
                } header: {
                    Text("Help & Resources")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showAPIKeyInfo) {
                APIKeyInfoView()
            }
            .alert("Success", isPresented: $showSaveSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("API Key saved successfully!")
            }
            .onAppear {
                apiKey = viewModel.geminiAPIKey
            }
        }
    }

    private var statusIcon: String {
        switch viewModel.voiceService.authorizationStatus {
        case .authorized:
            return "checkmark.circle.fill"
        case .denied, .restricted:
            return "xmark.circle.fill"
        default:
            return "questionmark.circle.fill"
        }
    }

    private var statusColor: Color {
        switch viewModel.voiceService.authorizationStatus {
        case .authorized:
            return .green
        case .denied, .restricted:
            return .red
        default:
            return .orange
        }
    }

    private func saveAPIKey() {
        viewModel.saveAPIKey(apiKey)
        showSaveSuccess = true
    }

    private func requestMicrophonePermission() {
        viewModel.voiceService.requestAuthorization()
    }

    private func clearCache() {
        // Clear any cached data
        URLCache.shared.removeAllCachedResponses()
    }
}

struct APIKeyInfoView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Voice Commands Help
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Voice Commands")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Speak UPC codes clearly:")
                            .font(.headline)

                        Text("Say each digit individually with brief pauses:")
                            .font(.body)
                            .foregroundColor(.secondary)

                        Text("Example: \"zero seven two one six five zero zero zero one two three\"")
                            .font(.caption)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)

                        Divider()

                        Text("Natural Language Commands:")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 8) {
                            CommandExample(command: "Add to inventory", description: "Adds current product")
                            CommandExample(command: "How much do we have?", description: "Shows inventory count")
                            CommandExample(command: "Find [product name]", description: "Searches inventory")
                        }
                    }

                    Divider()

                    // API Key Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Getting Your API Key")
                            .font(.title2)
                            .fontWeight(.bold)

                        NumberedStep(number: 1, text: "Visit ai.google.dev")
                        NumberedStep(number: 2, text: "Sign in with your Google account")
                        NumberedStep(number: 3, text: "Navigate to 'Get API Key'")
                        NumberedStep(number: 4, text: "Create a new API key for Gemini")
                        NumberedStep(number: 5, text: "Copy and paste it into the settings")

                        Text("Note: Free tier includes 60 requests per minute")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Help")
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
}

struct CommandExample: View {
    let command: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "mic.fill")
                .foregroundColor(.blue)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(command)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct NumberedStep: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.blue)
                .clipShape(Circle())

            Text(text)
                .font(.body)
        }
    }
}
