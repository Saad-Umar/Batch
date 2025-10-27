import SwiftUI

struct TranslationHistoryView: View {
    let history: [TranslationResult]
    let onDelete: (TranslationResult) -> Void
    let onSpeak: (TranslationResult) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Translations")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            LazyVStack(spacing: 8) {
                ForEach(history.prefix(5)) { translation in
                    TranslationHistoryRow(
                        translation: translation,
                        onSpeak: { onSpeak(translation) },
                        onDelete: { onDelete(translation) }
                    )
                }
            }
            
            if history.count > 5 {
                Text("Showing 5 of \(history.count) translations")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
    }
}

struct TranslationHistoryRow: View {
    let translation: TranslationResult
    let onSpeak: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Language indicators
            VStack(spacing: 4) {
                Text(translation.sourceLanguage.flag)
                    .font(.caption)
                Image(systemName: "arrow.down")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(translation.targetLanguage.flag)
                    .font(.caption)
            }
            .frame(width: 24)
            
            // Translation content
            VStack(alignment: .leading, spacing: 4) {
                Text(translation.sourceText)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(translation.translatedText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                    .lineLimit(2)
                
                Text(translation.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.tertiary)
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                Button(action: onSpeak) {
                    Image(systemName: "speaker.wave.2")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}