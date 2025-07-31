import Foundation
import Speech
import AVFoundation

/// Service for handling speech recognition functionality
@MainActor
class SpeechRecognitionService: ObservableObject {
    @Published var isListening = false
    @Published var recognizedText = ""
    @Published var errorMessage: String?
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init() {
        setupSpeechRecognizer()
    }
    
    /// Sets up the speech recognizer for the current locale
    private func setupSpeechRecognizer() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale.current)
        speechRecognizer?.delegate = self
    }
    
    /// Updates the speech recognizer for a specific language
    func updateLanguage(_ language: Language) {
        let locale = Locale(identifier: language.code)
        speechRecognizer = SFSpeechRecognizer(locale: locale)
        speechRecognizer?.delegate = self
    }
    
    /// Requests authorization for speech recognition
    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    continuation.resume(returning: status == .authorized)
                }
            }
        }
    }
    
    /// Requests authorization for microphone access
    func requestMicrophoneAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    /// Starts speech recognition
    func startRecording() async throws {
        // Cancel any previous recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechRecognitionError.recognitionRequestFailed
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Configure audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        // Start recognition
        guard let speechRecognizer = speechRecognizer else {
            throw SpeechRecognitionError.recognizerNotAvailable
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                if let result = result {
                    self?.recognizedText = result.bestTranscription.formattedString
                }
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.stopRecording()
                }
            }
        }
        
        isListening = true
        recognizedText = ""
        errorMessage = nil
    }
    
    /// Stops speech recognition
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isListening = false
    }
}

// MARK: - SFSpeechRecognizerDelegate
extension SpeechRecognitionService: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available {
            errorMessage = "Speech recognition is not available"
            stopRecording()
        }
    }
}

// MARK: - Error Types
enum SpeechRecognitionError: LocalizedError {
    case recognitionRequestFailed
    case recognizerNotAvailable
    case audioEngineError
    
    var errorDescription: String? {
        switch self {
        case .recognitionRequestFailed:
            return "Failed to create speech recognition request"
        case .recognizerNotAvailable:
            return "Speech recognizer is not available"
        case .audioEngineError:
            return "Audio engine error occurred"
        }
    }
}