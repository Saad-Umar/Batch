import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TranslationViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Language Selection Header
                LanguageSelectionView(viewModel: viewModel)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Main Translation Area
                ScrollView {
                    VStack(spacing: 20) {
                        // Current Translation Display
                        if let translation = viewModel.currentTranslation {
                            TranslationCardView(
                                translation: translation,
                                onSpeakOriginal: { viewModel.speakOriginal() },
                                onSpeakTranslation: { viewModel.speakTranslation() }
                            )
                            .padding(.horizontal)
                        } else if viewModel.isListening {
                            // Live Recognition Display
                            LiveRecognitionView(
                                recognizedText: viewModel.recognizedText,
                                sourceLanguage: viewModel.sourceLanguage
                            )
                            .padding(.horizontal)
                        } else {
                            // Welcome Message
                            WelcomeView()
                                .padding(.horizontal)
                        }
                        
                        // Translation History
                        if !viewModel.translationHistory.isEmpty {
                            TranslationHistoryView(
                                history: viewModel.translationHistory,
                                onDelete: viewModel.deleteTranslation,
                                onSpeak: { translation in
                                    viewModel.currentTranslation = translation
                                    viewModel.speakTranslation()
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                
                // Bottom Controls
                VoiceControlsView(viewModel: viewModel)
                    .padding()
                    .background(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
            }
            .navigationTitle("Voice Translator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Clear History", action: viewModel.clearHistory)
                        Button("Stop Speaking", action: viewModel.stopSpeaking)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingLanguagePicker) {
                LanguagePickerView(
                    selectedLanguage: viewModel.languagePickerMode == .source ? 
                        viewModel.sourceLanguage : viewModel.targetLanguage,
                    onLanguageSelected: { language in
                        if viewModel.languagePickerMode == .source {
                            viewModel.selectSourceLanguage(language)
                        } else {
                            viewModel.selectTargetLanguage(language)
                        }
                    }
                )
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .task {
            await viewModel.requestPermissions()
        }
    }
}