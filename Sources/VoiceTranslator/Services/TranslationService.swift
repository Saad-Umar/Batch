import Foundation
import Translation

/// Service for handling text translation functionality
@MainActor
class TranslationService: ObservableObject {
    @Published var isTranslating = false
    @Published var errorMessage: String?
    
    /// Translates text from source language to target language
    func translate(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async throws -> String {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TranslationError.emptyText
        }
        
        guard sourceLanguage != targetLanguage else {
            return text // No translation needed
        }
        
        isTranslating = true
        errorMessage = nil
        
        defer {
            isTranslating = false
        }
        
        do {
            // Create translation session
            let configuration = TranslationSession.Configuration(
                source: Locale.Language(identifier: sourceLanguage.code),
                target: Locale.Language(identifier: targetLanguage.code)
            )
            
            let session = TranslationSession(configuration: configuration)
            
            // Perform translation
            let request = TranslationSession.Request(sourceText: text)
            let response = try await session.translate(request)
            
            return response.targetText
            
        } catch {
            errorMessage = error.localizedDescription
            throw TranslationError.translationFailed(error.localizedDescription)
        }
    }
    
    /// Batch translates multiple texts
    func translateBatch(
        texts: [String],
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async throws -> [String] {
        guard !texts.isEmpty else {
            throw TranslationError.emptyText
        }
        
        var results: [String] = []
        
        for text in texts {
            let translatedText = try await translate(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
            results.append(translatedText)
        }
        
        return results
    }
}

// MARK: - Error Types
enum TranslationError: LocalizedError {
    case emptyText
    case translationFailed(String)
    case unsupportedLanguage
    
    var errorDescription: String? {
        switch self {
        case .emptyText:
            return "No text to translate"
        case .translationFailed(let message):
            return "Translation failed: \(message)"
        case .unsupportedLanguage:
            return "Language not supported for translation"
        }
    }
}