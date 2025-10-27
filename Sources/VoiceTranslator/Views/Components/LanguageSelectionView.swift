import SwiftUI

struct LanguageSelectionView: View {
    @ObservedObject var viewModel: TranslationViewModel
    
    var body: some View {
        HStack {
            // Source Language Button
            Button {
                viewModel.languagePickerMode = .source
                viewModel.showingLanguagePicker = true
            } label: {
                LanguageButtonView(language: viewModel.sourceLanguage)
            }
            
            Spacer()
            
            // Swap Languages Button
            Button {
                viewModel.swapLanguages()
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Target Language Button
            Button {
                viewModel.languagePickerMode = .target
                viewModel.showingLanguagePicker = true
            } label: {
                LanguageButtonView(language: viewModel.targetLanguage)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct LanguageButtonView: View {
    let language: Language
    
    var body: some View {
        VStack(spacing: 4) {
            Text(language.flag)
                .font(.largeTitle)
            
            Text(language.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .frame(width: 80, height: 60)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}