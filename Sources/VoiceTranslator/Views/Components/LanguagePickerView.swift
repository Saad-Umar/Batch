import SwiftUI

struct LanguagePickerView: View {
    let selectedLanguage: Language
    let onLanguageSelected: (Language) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(Language.allCases) { language in
                Button {
                    onLanguageSelected(language)
                } label: {
                    HStack {
                        Text(language.flag)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(language.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(language.code.uppercased())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if language.id == selectedLanguage.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Select Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}