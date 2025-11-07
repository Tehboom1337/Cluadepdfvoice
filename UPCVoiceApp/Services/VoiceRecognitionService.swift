//
//  VoiceRecognitionService.swift
//  UPCVoiceApp
//
//  Service for handling voice input and speech recognition
//

import Foundation
import Speech
import AVFoundation

class VoiceRecognitionService: ObservableObject {
    @Published var recognizedText: String = ""
    @Published var isRecording: Bool = false
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    init() {
        requestAuthorization()
    }

    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
            }
        }
    }

    func startRecording() throws {
        // Cancel any existing task
        recognitionTask?.cancel()
        recognitionTask = nil

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw VoiceRecognitionError.unableToCreateRequest
        }

        recognitionRequest.shouldReportPartialResults = true

        // Get audio input node
        let inputNode = audioEngine.inputNode

        // Create recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            var isFinal = false

            if let result = result {
                DispatchQueue.main.async {
                    self?.recognizedText = result.bestTranscription.formattedString
                }
                isFinal = result.isFinal
            }

            if error != nil || isFinal {
                self?.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self?.recognitionRequest = nil
                self?.recognitionTask = nil

                DispatchQueue.main.async {
                    self?.isRecording = false
                }
            }
        }

        // Configure microphone input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()

        DispatchQueue.main.async {
            self.isRecording = true
            self.recognizedText = ""
        }
    }

    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()

        DispatchQueue.main.async {
            self.isRecording = false
        }
    }

    // Extract UPC from recognized text
    func extractUPC(from text: String) -> String? {
        // Remove spaces and non-numeric characters
        let cleaned = text.replacingOccurrences(of: " ", with: "")
                         .replacingOccurrences(of: "-", with: "")

        // Extract numeric sequences
        let pattern = "\\d+"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let matches = regex.matches(in: cleaned, range: NSRange(cleaned.startIndex..., in: cleaned))

            for match in matches {
                if let range = Range(match.range, in: cleaned) {
                    let upc = String(cleaned[range])
                    // UPC-A is 12 digits, UPC-E is 8 digits
                    if upc.count == 12 || upc.count == 8 {
                        return upc
                    }
                }
            }
        }

        return nil
    }
}

enum VoiceRecognitionError: Error {
    case unableToCreateRequest
    case audioEngineFailure
    case authorizationDenied
}
