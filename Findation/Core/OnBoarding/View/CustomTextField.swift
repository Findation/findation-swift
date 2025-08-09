import SwiftUI

struct CustomTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !label.isEmpty {
                Text(label)
            }
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.secondary)
                }
                if isSecure {
                    SecureField("", text: $text)
                        .focused($isFocused)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                } else {
                    TextField("", text: $text)
                        .focused($isFocused)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                        .textContentType(.username)
                }
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }

            Divider().background(.gray.opacity(0.5))
        }
        .padding(.horizontal, 20)
    }}

#Preview {
    CustomTextField(label:"라벨",placeholder: "example@example.com", text: .constant(""), isSecure: false)
}
