import Foundation
import AVFoundation

/// Service for handling text-to-speech functionality
@MainActor
class TextToSpeechService: NSObject, ObservableObject {
    @Published var isSpeaking = false
    @Published var errorMessage: String?
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    override init() {
        super.init()
        speechSynthesizer.delegate = self
    }
    
    /// Speaks the given text in the specified language
    func speak(text: String, in language: Language) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "No text to speak"
            return
        }
        
        // Stop any current speech
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        // Create speech utterance
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language.code)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // Configure audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            errorMessage = "Failed to configure audio session: \(error.localizedDescription)"
            return
        }
        
        // Speak the text
        speechSynthesizer.speak(utterance)
        isSpeaking = true
        errorMessage = nil
    }
    
    /// Stops current speech
    func stopSpeaking() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    /// Pauses current speech
    func pauseSpeaking() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.pauseSpeaking(at: .immediate)
        }
    }
    
    /// Continues paused speech
    func continueSpeaking() {
        if speechSynthesizer.isPaused {
            speechSynthesizer.continueSpeaking()
        }
    }
    
    /// Gets available voices for a specific language
    func availableVoices(for language: Language) -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices().filter { voice in
            voice.language.hasPrefix(language.code)
        }
    }
    
    /// Checks if a language is supported for speech synthesis
    func isLanguageSupported(_ language: Language) -> Bool {
        return !availableVoices(for: language).isEmpty
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension TextToSpeechService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        isSpeaking = true
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        // Keep isSpeaking as true when paused
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        isSpeaking = true
    }
}