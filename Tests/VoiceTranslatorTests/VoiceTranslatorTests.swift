import XCTest
@testable import VoiceTranslator

final class VoiceTranslatorTests: XCTestCase {
    
    // MARK: - Language Model Tests
    
    func testLanguageModel() {
        let english = Language.defaultSource
        XCTAssertEqual(english.code, "en")
        XCTAssertEqual(english.name, "English")
        XCTAssertEqual(english.flag, "🇺🇸")
        
        let spanish = Language.defaultTarget
        XCTAssertEqual(spanish.code, "es")
        XCTAssertEqual(spanish.name, "Spanish")
        XCTAssertEqual(spanish.flag, "🇪🇸")
    }
    
    func testLanguageCollection() {
        XCTAssertFalse(Language.allCases.isEmpty)
        XCTAssertTrue(Language.allCases.count >= 12)
        
        // Test that all languages have unique IDs
        let ids = Language.allCases.map { $0.id }
        let uniqueIds = Set(ids)
        XCTAssertEqual(ids.count, uniqueIds.count)
    }
    
    // MARK: - Translation Result Tests
    
    func testTranslationResult() {
        let sourceLanguage = Language.defaultSource
        let targetLanguage = Language.defaultTarget
        let sourceText = "Hello, world!"
        let translatedText = "¡Hola, mundo!"
        
        let result = TranslationResult(
            sourceText: sourceText,
            translatedText: translatedText,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )
        
        XCTAssertEqual(result.sourceText, sourceText)
        XCTAssertEqual(result.translatedText, translatedText)
        XCTAssertEqual(result.sourceLanguage.code, sourceLanguage.code)
        XCTAssertEqual(result.targetLanguage.code, targetLanguage.code)
        XCTAssertNotNil(result.id)
        XCTAssertTrue(result.timestamp.timeIntervalSinceNow < 1) // Should be recent
    }
    
    // MARK: - Translation Service Tests
    
    @MainActor
    func testTranslationServiceInitialization() {
        let service = TranslationService()
        XCTAssertFalse(service.isTranslating)
        XCTAssertNil(service.errorMessage)
    }
    
    @MainActor
    func testTranslationErrorHandling() async {
        let service = TranslationService()
        
        do {
            // Test empty text
            _ = try await service.translate(
                text: "",
                from: Language.defaultSource,
                to: Language.defaultTarget
            )
            XCTFail("Should have thrown an error for empty text")
        } catch {
            XCTAssertTrue(error is TranslationError)
        }
        
        do {
            // Test same language translation
            let result = try await service.translate(
                text: "Hello",
                from: Language.defaultSource,
                to: Language.defaultSource
            )
            XCTAssertEqual(result, "Hello") // Should return same text
        } catch {
            XCTFail("Same language translation should not throw error")
        }
    }
    
    // MARK: - Text-to-Speech Service Tests
    
    @MainActor
    func testTextToSpeechServiceInitialization() {
        let service = TextToSpeechService()
        XCTAssertFalse(service.isSpeaking)
        XCTAssertNil(service.errorMessage)
    }
    
    @MainActor
    func testTextToSpeechLanguageSupport() {
        let service = TextToSpeechService()
        
        // Test that common languages are supported
        let english = Language.allCases.first { $0.code == "en" }!
        XCTAssertTrue(service.isLanguageSupported(english))
        
        let voices = service.availableVoices(for: english)
        XCTAssertFalse(voices.isEmpty)
    }
    
    // MARK: - Speech Recognition Service Tests
    
    @MainActor
    func testSpeechRecognitionServiceInitialization() {
        let service = SpeechRecognitionService()
        XCTAssertFalse(service.isListening)
        XCTAssertEqual(service.recognizedText, "")
        XCTAssertNil(service.errorMessage)
    }
    
    @MainActor
    func testSpeechRecognitionLanguageUpdate() {
        let service = SpeechRecognitionService()
        let spanish = Language.allCases.first { $0.code == "es" }!
        
        // This should not crash
        service.updateLanguage(spanish)
        XCTAssertFalse(service.isListening) // Should remain false
    }
    
    // MARK: - Translation View Model Tests
    
    @MainActor
    func testTranslationViewModelInitialization() {
        let viewModel = TranslationViewModel()
        
        XCTAssertEqual(viewModel.sourceLanguage.code, "en")
        XCTAssertEqual(viewModel.targetLanguage.code, "es")
        XCTAssertTrue(viewModel.translationHistory.isEmpty)
        XCTAssertNil(viewModel.currentTranslation)
        XCTAssertFalse(viewModel.isProcessing)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showingLanguagePicker)
    }
    
    @MainActor
    func testLanguageSelection() {
        let viewModel = TranslationViewModel()
        let french = Language.allCases.first { $0.code == "fr" }!
        let german = Language.allCases.first { $0.code == "de" }!
        
        // Test source language selection
        viewModel.selectSourceLanguage(french)
        XCTAssertEqual(viewModel.sourceLanguage.code, "fr")
        XCTAssertFalse(viewModel.showingLanguagePicker)
        
        // Test target language selection
        viewModel.selectTargetLanguage(german)
        XCTAssertEqual(viewModel.targetLanguage.code, "de")
        XCTAssertFalse(viewModel.showingLanguagePicker)
    }
    
    @MainActor
    func testLanguageSwapping() {
        let viewModel = TranslationViewModel()
        let originalSource = viewModel.sourceLanguage
        let originalTarget = viewModel.targetLanguage
        
        viewModel.swapLanguages()
        
        XCTAssertEqual(viewModel.sourceLanguage.code, originalTarget.code)
        XCTAssertEqual(viewModel.targetLanguage.code, originalSource.code)
    }
    
    @MainActor
    func testTranslationHistoryManagement() {
        let viewModel = TranslationViewModel()
        
        // Create a mock translation
        let translation = TranslationResult(
            sourceText: "Hello",
            translatedText: "Hola",
            sourceLanguage: Language.defaultSource,
            targetLanguage: Language.defaultTarget
        )
        
        // Add to history
        viewModel.translationHistory.append(translation)
        viewModel.currentTranslation = translation
        
        XCTAssertEqual(viewModel.translationHistory.count, 1)
        XCTAssertNotNil(viewModel.currentTranslation)
        
        // Test deletion
        viewModel.deleteTranslation(translation)
        XCTAssertTrue(viewModel.translationHistory.isEmpty)
        XCTAssertNil(viewModel.currentTranslation)
        
        // Test clear history
        viewModel.translationHistory.append(translation)
        viewModel.currentTranslation = translation
        viewModel.clearHistory()
        XCTAssertTrue(viewModel.translationHistory.isEmpty)
        XCTAssertNil(viewModel.currentTranslation)
    }
    
    @MainActor
    func testErrorHandling() {
        let viewModel = TranslationViewModel()
        
        viewModel.errorMessage = "Test error"
        XCTAssertEqual(viewModel.errorMessage, "Test error")
        
        viewModel.clearError()
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Error Types Tests
    
    func testTranslationErrors() {
        let emptyTextError = TranslationError.emptyText
        XCTAssertEqual(emptyTextError.errorDescription, "No text to translate")
        
        let failedError = TranslationError.translationFailed("Network error")
        XCTAssertEqual(failedError.errorDescription, "Translation failed: Network error")
        
        let unsupportedError = TranslationError.unsupportedLanguage
        XCTAssertEqual(unsupportedError.errorDescription, "Language not supported for translation")
    }
    
    func testSpeechRecognitionErrors() {
        let requestFailedError = SpeechRecognitionError.recognitionRequestFailed
        XCTAssertEqual(requestFailedError.errorDescription, "Failed to create speech recognition request")
        
        let unavailableError = SpeechRecognitionError.recognizerNotAvailable
        XCTAssertEqual(unavailableError.errorDescription, "Speech recognizer is not available")
        
        let audioEngineError = SpeechRecognitionError.audioEngineError
        XCTAssertEqual(audioEngineError.errorDescription, "Audio engine error occurred")
    }
    
    // MARK: - Performance Tests
    
    func testLanguageAllCasesPerformance() {
        measure {
            _ = Language.allCases
        }
    }
    
    @MainActor
    func testViewModelInitializationPerformance() {
        measure {
            _ = TranslationViewModel()
        }
    }
}