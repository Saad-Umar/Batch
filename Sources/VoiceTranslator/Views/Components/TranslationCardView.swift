import SwiftUI

struct TranslationCardView: View {
    let translation: TranslationResult
    let onSpeakOriginal: () -> Void
    let onSpeakTranslation: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Source Text
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(translation.sourceLanguage.flag)
                        .font(.title2)
                    Text(translation.sourceLanguage.name)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: onSpeakOriginal) {
                        Image(systemName: "speaker.wave.2")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
                
                Text(translation.sourceText)
                    .font(.body)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Arrow Indicator
            Image(systemName: "arrow.down")
                .font(.title2)
                .foregroundColor(.secondary)
            
            // Translated Text
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(translation.targetLanguage.flag)
                        .font(.title2)
                    Text(translation.targetLanguage.name)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: onSpeakTranslation) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title3)
                            .foregroundColor(.green)
                    }
                }
                
                Text(translation.translatedText)
                    .font(.body)
                    .fontWeight(.medium)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
            
            // Timestamp
            Text(translation.timestamp, style: .time)
                .font(.caption2)
                .foregroundColor(.tertiary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}