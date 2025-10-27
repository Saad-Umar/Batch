import SwiftUI

struct LiveRecognitionView: View {
    let recognizedText: String
    let sourceLanguage: Language
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text(sourceLanguage.flag)
                    .font(.title2)
                Text("Listening in \(sourceLanguage.name)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Pulsing indicator
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
                    .scaleEffect(1.0)
                    .animation(
                        .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                        value: true
                    )
            }
            
            // Recognition Text Area
            VStack(alignment: .leading, spacing: 12) {
                if recognizedText.isEmpty {
                    // Placeholder when no speech detected
                    VStack(spacing: 8) {
                        Image(systemName: "waveform")
                            .font(.system(size: 40))
                            .foregroundColor(.blue.opacity(0.6))
                        
                        Text("Start speaking...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    // Live recognized text
                    Text(recognizedText)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                        .animation(.easeInOut(duration: 0.2), value: recognizedText)
                }
            }
            
            // Instructions
            Text("Release to translate")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}