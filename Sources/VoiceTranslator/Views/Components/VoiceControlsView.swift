import SwiftUI

struct VoiceControlsView: View {
    @ObservedObject var viewModel: TranslationViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Status Text
            if viewModel.isProcessing {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text(statusText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if !viewModel.recognizedText.isEmpty && !viewModel.isListening {
                Text("Tap to translate again")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Tap and hold to speak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Main Voice Button
            Button {
                if viewModel.isListening {
                    viewModel.stopListening()
                } else {
                    Task {
                        await viewModel.startListening()
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(buttonColor)
                        .frame(width: 80, height: 80)
                        .scaleEffect(viewModel.isListening ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: viewModel.isListening)
                    
                    Image(systemName: buttonIcon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .disabled(viewModel.isProcessing && !viewModel.isListening)
            .scaleEffect(viewModel.isListening ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isListening)
            
            // Secondary Controls
            HStack(spacing: 20) {
                // Stop Speaking Button
                if viewModel.isSpeaking {
                    Button {
                        viewModel.stopSpeaking()
                    } label: {
                        Image(systemName: "stop.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
                
                // Replay Translation Button
                if viewModel.currentTranslation != nil && !viewModel.isSpeaking {
                    Button {
                        viewModel.speakTranslation()
                    } label: {
                        Image(systemName: "speaker.wave.2.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.isSpeaking)
        }
    }
    
    private var buttonColor: Color {
        if viewModel.isListening {
            return .red
        } else if viewModel.isProcessing {
            return .gray
        } else {
            return .blue
        }
    }
    
    private var buttonIcon: String {
        if viewModel.isListening {
            return "stop.fill"
        } else {
            return "mic.fill"
        }
    }
    
    private var statusText: String {
        if viewModel.isListening {
            return "Listening..."
        } else if viewModel.isTranslating {
            return "Translating..."
        } else if viewModel.isSpeaking {
            return "Speaking..."
        } else {
            return "Processing..."
        }
    }
}