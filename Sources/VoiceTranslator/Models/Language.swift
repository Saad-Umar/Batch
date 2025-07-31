import Foundation

/// Represents a language supported by the translation system
struct Language: Identifiable, Hashable, CaseIterable {
    let id: String
    let name: String
    let code: String
    let flag: String
    
    static let allCases: [Language] = [
        Language(id: "en", name: "English", code: "en", flag: "🇺🇸"),
        Language(id: "es", name: "Spanish", code: "es", flag: "🇪🇸"),
        Language(id: "fr", name: "French", code: "fr", flag: "🇫🇷"),
        Language(id: "de", name: "German", code: "de", flag: "🇩🇪"),
        Language(id: "it", name: "Italian", code: "it", flag: "🇮🇹"),
        Language(id: "pt", name: "Portuguese", code: "pt", flag: "🇵🇹"),
        Language(id: "ru", name: "Russian", code: "ru", flag: "🇷🇺"),
        Language(id: "ja", name: "Japanese", code: "ja", flag: "🇯🇵"),
        Language(id: "ko", name: "Korean", code: "ko", flag: "🇰🇷"),
        Language(id: "zh", name: "Chinese", code: "zh", flag: "🇨🇳"),
        Language(id: "ar", name: "Arabic", code: "ar", flag: "🇸🇦"),
        Language(id: "hi", name: "Hindi", code: "hi", flag: "🇮🇳"),
    ]
    
    /// Default source language (English)
    static let defaultSource = Language.allCases.first { $0.code == "en" }!
    
    /// Default target language (Spanish)
    static let defaultTarget = Language.allCases.first { $0.code == "es" }!
}