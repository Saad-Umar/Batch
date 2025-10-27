import Foundation

/// Represents the result of a translation operation
struct TranslationResult: Identifiable, Hashable {
    let id = UUID()
    let sourceText: String
    let translatedText: String
    let sourceLanguage: Language
    let targetLanguage: Language
    let timestamp: Date
    
    init(sourceText: String, translatedText: String, sourceLanguage: Language, targetLanguage: Language) {
        self.sourceText = sourceText
        self.translatedText = translatedText
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.timestamp = Date()
    }
}