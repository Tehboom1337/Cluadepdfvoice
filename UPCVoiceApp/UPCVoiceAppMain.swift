//
//  UPCVoiceAppMain.swift
//  UPCVoiceApp
//
//  Main app entry point
//

import SwiftUI

@main
struct UPCVoiceApp: App {
    @StateObject private var viewModel = MainViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
