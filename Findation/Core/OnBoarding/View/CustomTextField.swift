import SwiftUI

struct CustomTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding(.vertical, 8)
            } else {
                TextField(placeholder, text: $text)
                    .padding(.vertical, 8)
            }

            Divider()
                .background(Color.gray.opacity(0.5))
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    CustomTextField(label:"라벨",placeholder: "example@example.com", text: .constant(""), isSecure: false)
}
