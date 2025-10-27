import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 24) {
            // App Icon/Logo
            VStack(spacing: 16) {
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.blue, .green],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Voice Translator")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            // Features List
            VStack(spacing: 16) {
                FeatureRow(
                    icon: "mic.fill",
                    title: "Speak Naturally",
                    description: "Just tap and speak in your language"
                )
                
                FeatureRow(
                    icon: "arrow.left.arrow.right",
                    title: "Instant Translation",
                    description: "Get real-time translations between languages"
                )
                
                FeatureRow(
                    icon: "speaker.wave.2.fill",
                    title: "Hear Results",
                    description: "Listen to translations with natural voices"
                )
            }
            .padding(.horizontal)
            
            // Get Started Hint
            VStack(spacing: 8) {
                Image(systemName: "arrow.down")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .scaleEffect(1.0)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: true
                    )
                
                Text("Tap the microphone to get started")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}