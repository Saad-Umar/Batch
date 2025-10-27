import Foundation
import SwiftUI

/// Main view model that coordinates all translation functionality
@MainActor
class TranslationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var sourceLanguage = Language.defaultSource
    @Published var targetLanguage = Language.defaultTarget
    @Published var translationHistory: [TranslationResult] = []
    @Published var currentTranslation: TranslationResult?
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var showingLanguagePicker = false
    @Published var languagePickerMode: LanguagePickerMode = .source
    
    // MARK: - Services
    private let speechRecognitionService = SpeechRecognitionService()
    private let translationService = TranslationService()
    private let textToSpeechService = TextToSpeechService()
    
    // MARK: - Computed Properties
    var isListening: Bool {
        speechRecognitionService.isListening
    }
    
    var isTranslating: Bool {
        translationService.isTranslating
    }
    
    var isSpeaking: Bool {
        textToSpeechService.isSpeaking
    }
    
    var recognizedText: String {
        speechRecognitionService.recognizedText
    }
    
    // MARK: - Initialization
    init() {
        setupServices()
    }
    
    // MARK: - Setup
    private func setupServices() {
        speechRecognitionService.updateLanguage(sourceLanguage)
    }
    
    // MARK: - Permission Handling
    func requestPermissions() async {
        let speechAuthorized = await speechRecognitionService.requestAuthorization()
        let microphoneAuthorized = await speechRecognitionService.requestMicrophoneAuthorization()
        
        if !speechAuthorized {
            errorMessage = "Speech recognition permission is required"
        } else if !microphoneAuthorized {
            errorMessage = "Microphone permission is required"
        }
    }
    
    // MARK: - Language Selection
    func selectSourceLanguage(_ language: Language) {
        sourceLanguage = language
        speechRecognitionService.updateLanguage(language)
        showingLanguagePicker = false
    }
    
    func selectTargetLanguage(_ language: Language) {
        targetLanguage = language
        showingLanguagePicker = false
    }
    
    func swapLanguages() {
        let temp = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = temp
        speechRecognitionService.updateLanguage(sourceLanguage)
    }
    
    // MARK: - Speech Recognition
    func startListening() async {
        guard !isListening else { return }
        
        isProcessing = true
        errorMessage = nil
        
        do {
            try await speechRecognitionService.startRecording()
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
            isProcessing = false
        }
    }
    
    func stopListening() {
        speechRecognitionService.stopRecording()
        
        // Auto-translate if we have recognized text
        if !recognizedText.isEmpty {
            Task {
                await translateRecognizedText()
            }
        }
        
        isProcessing = false
    }
    
    // MARK: - Translation
    private func translateRecognizedText() async {
        let textToTranslate = recognizedText
        guard !textToTranslate.isEmpty else { return }
        
        isProcessing = true
        
        do {
            let translatedText = try await translationService.translate(
                text: textToTranslate,
                from: sourceLanguage,
                to: targetLanguage
            )
            
            let result = TranslationResult(
                sourceText: textToTranslate,
                translatedText: translatedText,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage
            )
            
            currentTranslation = result
            translationHistory.insert(result, at: 0)
            
            // Auto-speak the translation
            textToSpeechService.speak(text: translatedText, in: targetLanguage)
            
        } catch {
            errorMessage = "Translation failed: \(error.localizedDescription)"
        }
        
        isProcessing = false
    }
    
    func translateText(_ text: String) async {
        guard !text.isEmpty else { return }
        
        isProcessing = true
        errorMessage = nil
        
        do {
            let translatedText = try await translationService.translate(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
            
            let result = TranslationResult(
                sourceText: text,
                translatedText: translatedText,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage
            )
            
            currentTranslation = result
            translationHistory.insert(result, at: 0)
            
        } catch {
            errorMessage = "Translation failed: \(error.localizedDescription)"
        }
        
        isProcessing = false
    }
    
    // MARK: - Text-to-Speech
    func speakTranslation() {
        guard let translation = currentTranslation else { return }
        textToSpeechService.speak(text: translation.translatedText, in: targetLanguage)
    }
    
    func speakOriginal() {
        guard let translation = currentTranslation else { return }
        textToSpeechService.speak(text: translation.sourceText, in: sourceLanguage)
    }
    
    func stopSpeaking() {
        textToSpeechService.stopSpeaking()
    }
    
    // MARK: - History Management
    func clearHistory() {
        translationHistory.removeAll()
        currentTranslation = nil
    }
    
    func deleteTranslation(_ translation: TranslationResult) {
        translationHistory.removeAll { $0.id == translation.id }
        if currentTranslation?.id == translation.id {
            currentTranslation = translationHistory.first
        }
    }
    
    // MARK: - Error Handling
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Supporting Types
enum LanguagePickerMode {
    case source
    case target
}